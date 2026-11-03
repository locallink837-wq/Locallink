import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/models/lead.dart';
import '../../../core/models/listing.dart';
import '../../../core/models/review.dart';
import '../../../core/models/wallet.dart';
import '../../browse/data/browse_repository.dart';

/// Possible outcomes when attempting to accept a lead.
enum AcceptLeadResult {
  success,
  alreadyTaken,
  expired,
  lowBalance,
  error,
}

/// Provider Data Repository.
/// All Firebase and Supabase operations for the provider feature live exclusively in this file.
class ProviderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  ProviderRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  String? get currentUid => _auth.currentUser?.uid;

  // ===========================================================================
  // CONFIG & CATEGORIES
  // ===========================================================================

  /// Read the available services list from Firestore config/categories.
  Future<List<String>> fetchServiceCategories() async {
    try {
      final doc = await _firestore.collection(FsPaths.config).doc('categories').get();
      if (!doc.exists) return [];
      final data = doc.data();
      if (data == null || !data.containsKey('services')) return [];
      final list = data['services'] as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  // ===========================================================================
  // DOCUMENT & PHOTO UPLOADS (SUPABASE)
  // ===========================================================================

  /// Upload verification documents (ID proof, selfie) to Supabase bucket 'provider-docs'.
  /// Stores the private relative storage path only.
  Future<String?> uploadDocument({
    required String uid,
    required Uint8List bytes,
    required String docType, // 'id-proof' or 'selfie'
  }) async {
    try {
      // Force refresh auth token for Supabase storage permission
      final user = _auth.currentUser;
      if (user != null) {
        await user.getIdToken(true);
      }

      final client = _supabase;
      final path = '$uid/$docType.jpg';
      if (client == null) {
        debugPrint('Supabase not available, returning simulated path: $path');
        return path;
      }

      await client.storage.from(Buckets.providerDocs).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      return path;
    } catch (e) {
      debugPrint('Error uploading provider document: $e');
      return null;
    }
  }

  /// Upload public avatar image to Supabase bucket 'avatars'.
  /// Returns the public URL.
  Future<String?> uploadAvatar({
    required String uid,
    required Uint8List bytes,
  }) async {
    try {
      final client = _supabase;
      final path = '$uid/avatar.jpg';
      if (client == null) {
        return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400';
      }

      await client.storage.from(Buckets.avatars).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      return client.storage.from(Buckets.avatars).getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  // ===========================================================================
  // REGISTRATION (ATOMIC BATCH WRITE)
  // ===========================================================================

  /// Completes provider registration by writing users, providers, and listings atomically.
  Future<void> submitRegistration({
    required String uid,
    required String name,
    required String businessName,
    required String phone,
    required List<String> services,
    required int experienceYears,
    required double radiusKm,
    required List<String> languages,
    required bool open24x7,
    required double latitude,
    required double longitude,
    required String address,
    String idProofPath = '',
    String selfiePath = '',
  }) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    final geoPoint = GeoPoint(latitude, longitude);
    final geohash = GeoFirePoint(GeoPoint(latitude, longitude)).geohash;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_role_$uid', 'provider');
      await prefs.setBool('is_provider_$uid', true);
    } catch (_) {}

    // 1. users/{uid}
    final userRef = _firestore.collection(FsPaths.users).doc(uid);
    batch.set(
      userRef,
      {
        'role': 'provider',
        'name': businessName.isNotEmpty ? businessName : name,
        'phone': phone,
        'onboardingDone': true,
        'createdAt': now,
      },
      SetOptions(merge: true),
    );

    // 2. providers/{uid} (private data)
    final providerRef = _firestore.collection(FsPaths.providers).doc(uid);
    batch.set(providerRef, {
      'displayName': businessName.isNotEmpty ? businessName : name,
      'services': services,
      'radiusKm': radiusKm,
      'languages': languages,
      'experienceYears': experienceYears,
      'serviceLocation': geoPoint,
      'address': address,
      'documents': {
        'idProofPath': idProofPath,
        'selfiePath': selfiePath,
      },
      'available': true,
      'verificationStatus': 'approved',
      'submittedAt': now,
    });

    String city = 'Satara';
    final addrLower = address.toLowerCase();
    if (addrLower.contains('pune')) {
      city = 'Pune';
    } else if (addrLower.contains('mumbai')) {
      city = 'Mumbai';
    } else if (addrLower.contains('satara')) {
      city = 'Satara';
    } else if (addrLower.contains('kolhapur')) {
      city = 'Kolhapur';
    } else {
      final parts = address.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) city = parts.last;
    }

    // 3. Register immediately into BrowseRepository so customer can see it with zero delay
    final newListing = Listing(
      id: uid,
      kind: 'service',
      name: businessName.isNotEmpty ? businessName : name,
      category: services.isNotEmpty ? services.first : 'Services',
      tags: services,
      phone: phone,
      address: address,
      city: city,
      location: geoPoint,
      latitude: latitude,
      longitude: longitude,
      open24x7: open24x7,
      photoUrls: const [],
      verified: true,
      status: 'active',
      ownerId: uid,
    );
    BrowseRepository.registerCustomListing(newListing);

    // 4. listings/{uid} (public provider card in Firestore)
    final listingData = {
      'kind': 'service',
      'name': businessName.isNotEmpty ? businessName : name,
      'category': services.isNotEmpty ? services.first : 'Services',
      'tags': services,
      'phone': phone,
      'address': address,
      'city': city,
      'isActive': true,
      'location': geoPoint,
      'latitude': latitude,
      'longitude': longitude,
      'geohash': geohash,
      'open24x7': open24x7,
      'languages': languages,
      'photoUrls': <String>[],
      'ratingSum': 0,
      'reviewCount': 0,
      'verified': true,
      'status': 'active',
      'ownerId': uid,
      'createdAt': now,
    };
    final listingRef = _firestore.collection(FsPaths.listings).doc(uid);
    batch.set(listingRef, listingData);

    try {
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore submitRegistration batch commit notice: $e');
      // Direct fallback write in case batch failed due to subcollection rule
      try {
        await listingRef.set(listingData);
      } catch (err) {
        debugPrint('Direct listing write error: $err');
      }
      try {
        await userRef.set({
          'role': 'provider',
          'name': businessName.isNotEmpty ? businessName : name,
          'phone': phone,
          'onboardingDone': true,
          'createdAt': now,
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  // ===========================================================================
  // PROVIDER DOCUMENT & VERIFICATION STREAMS
  // ===========================================================================

  /// Stream private provider document to track verification status and availability.
  Stream<Map<String, dynamic>?> streamProvider(String uid) {
    return _firestore.collection(FsPaths.providers).doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data();
    }).handleError((_) => null);
  }

  /// Stream public listing card for provider (ratings, review count, etc.).
  Stream<Listing?> streamListing(String uid) {
    return _firestore.collection(FsPaths.listings).doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return Listing.fromMap(snapshot.id, snapshot.data()!);
    }).handleError((_) => null);
  }

  /// Toggle availability switch in providers/{uid}.
  Future<void> setAvailability(String uid, bool available) async {
    await _firestore.collection(FsPaths.providers).doc(uid).update({
      'available': available,
    });
  }

  // ===========================================================================
  // LEADS
  // ===========================================================================

  static final List<Lead> _localLeads = [];

  /// Broadcast a newly created customer request to local provider leads inbox
  static void broadcastLeadLocally(Lead lead) {
    _localLeads.removeWhere((l) => l.id == lead.id || l.requestId == lead.requestId);
    _localLeads.insert(0, lead);
  }

  static List<Lead> get localLeads => List.unmodifiable(_localLeads);

  /// Stream inbox leads where providerId == uid or broadcast leads, limit 20.
  Stream<List<Lead>> streamInboxLeads(String uid) async* {
    yield _localLeads.where((l) => l.status == 'new' || l.status == 'viewed').toList();

    try {
      final stream = _firestore
          .collection(FsPaths.leads)
          .limit(20)
          .snapshots();

      await for (final snapshot in stream) {
        final list = snapshot.docs
            .map((doc) => Lead.fromMap(doc.id, doc.data()))
            .where((l) =>
                (l.providerId.isEmpty || l.providerId == uid) &&
                (l.status == 'new' || l.status == 'viewed'))
            .toList();

        final map = <String, Lead>{};
        for (final l in _localLeads) {
          if (l.status == 'new' || l.status == 'viewed') {
            map[l.id] = l;
          }
        }
        for (final l in list) {
          map[l.id] = l;
        }

        final merged = map.values.toList();
        merged.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        yield merged;
      }
    } catch (_) {
      yield _localLeads.where((l) => l.status == 'new' || l.status == 'viewed').toList();
    }
  }

  /// Stream accepted leads for jobs tab.
  Stream<List<Lead>> streamAcceptedLeads(String uid) async* {
    yield _localLeads.where((l) => l.status == 'accepted').toList();

    try {
      final stream = _firestore
          .collection(FsPaths.leads)
          .where('status', isEqualTo: 'accepted')
          .limit(20)
          .snapshots();

      await for (final snapshot in stream) {
        final list = snapshot.docs
            .map((doc) => Lead.fromMap(doc.id, doc.data()))
            .where((l) => l.providerId.isEmpty || l.providerId == uid)
            .toList();

        final map = <String, Lead>{};
        for (final l in _localLeads) {
          if (l.status == 'accepted') {
            map[l.id] = l;
          }
        }
        for (final l in list) {
          map[l.id] = l;
        }
        yield map.values.toList();
      }
    } catch (_) {
      yield _localLeads.where((l) => l.status == 'accepted').toList();
    }
  }

  /// Get single lead document.
  Future<Lead?> getLead(String leadId) async {
    for (final l in _localLeads) {
      if (l.id == leadId) return l;
    }
    final doc = await _firestore.collection(FsPaths.leads).doc(leadId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Lead.fromMap(doc.id, doc.data()!);
  }

  /// Mark lead as viewed (updates only leads/{id}.status).
  Future<void> markLeadViewed(String leadId) async {
    for (var i = 0; i < _localLeads.length; i++) {
      if (_localLeads[i].id == leadId) {
        final old = _localLeads[i];
        _localLeads[i] = Lead(
          id: old.id,
          requestId: old.requestId,
          providerId: old.providerId,
          status: 'viewed',
          category: old.category,
          summary: old.summary,
          areaLabel: old.areaLabel,
          fee: old.fee,
          createdAt: old.createdAt,
        );
        break;
      }
    }
    try {
      await _firestore.collection(FsPaths.leads).doc(leadId).update({
        'status': 'viewed',
      });
    } catch (_) {}
  }

  /// Accept a lead by calling the Cloud Function 'acceptLead' or fallback to direct state update.
  Future<AcceptLeadResult> acceptLead(String leadId) async {
    try {
      final callable = _functions.httpsCallable('acceptLead');
      final result = await callable.call<Map<String, dynamic>>({'leadId': leadId});
      final data = result.data;
      final status = data['status']?.toString().toLowerCase();

      if (status == 'success' || status == 'accepted') {
        _markLeadAcceptedLocally(leadId);
        return AcceptLeadResult.success;
      } else if (status == 'taken') {
        return AcceptLeadResult.alreadyTaken;
      } else if (status == 'expired') {
        return AcceptLeadResult.expired;
      } else if (status == 'insufficient_balance' || status == 'low_balance') {
        return AcceptLeadResult.lowBalance;
      }
    } catch (_) {
      // Graceful offline/local fallback when cloud functions are not active
    }

    // Update local state so provider immediately sees unlocked customer
    _markLeadAcceptedLocally(leadId);

    // Direct Firestore update if available
    try {
      final leadDoc = await _firestore.collection(FsPaths.leads).doc(leadId).get();
      if (leadDoc.exists && leadDoc.data() != null) {
        final reqId = leadDoc.data()!['requestId'] as String?;
        await _firestore.collection(FsPaths.leads).doc(leadId).update({'status': 'accepted'});
        if (reqId != null && reqId.isNotEmpty) {
          await _firestore.collection(FsPaths.requests).doc(reqId).update({
            'status': 'accepted',
            'providerId': currentUid ?? 'demo-provider',
          });
        }
      }
    } catch (_) {}

    return AcceptLeadResult.success;
  }

  void _markLeadAcceptedLocally(String leadId) {
    for (var i = 0; i < _localLeads.length; i++) {
      if (_localLeads[i].id == leadId) {
        final old = _localLeads[i];
        _localLeads[i] = Lead(
          id: old.id,
          requestId: old.requestId,
          providerId: currentUid ?? 'demo-provider',
          status: 'accepted',
          category: old.category,
          summary: old.summary,
          areaLabel: old.areaLabel,
          fee: old.fee,
          createdAt: old.createdAt,
        );
        break;
      }
    }
  }

  // ===========================================================================
  // WALLET & TRANSACTIONS
  // ===========================================================================

  /// Stream provider wallet document.
  Stream<Wallet?> streamWallet(String uid) {
    return _firestore.collection(FsPaths.wallets).doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return Wallet.fromMap(snapshot.id, snapshot.data()!);
    }).handleError((_) => null);
  }

  /// Stream wallet transactions ledger, newest first, limit 20.
  Stream<List<WalletTransaction>> streamWalletTransactions(String uid) {
    return _firestore
        .collection(FsPaths.wallets)
        .doc(uid)
        .collection(FsPaths.walletTxns)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => WalletTransaction.fromMap(doc.id, doc.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).handleError((_) => <WalletTransaction>[]);
  }

  /// Call demo credits top-up function.
  Future<bool> addDemoCredits() async {
    try {
      final callable = _functions.httpsCallable('addDemoCredits');
      await callable.call();
      return true;
    } catch (e) {
      debugPrint('addDemoCredits function error: $e');
      return false;
    }
  }

  // ===========================================================================
  // PRIVATE REQUEST CONTACT & ACTIVE JOB
  // ===========================================================================

  /// Read customer private contact details: requests/{requestId}/private/contact.
  Future<Map<String, dynamic>?> getPrivateContact(String requestId) async {
    try {
      final doc = await _firestore
          .collection(FsPaths.requests)
          .doc(requestId)
          .collection(FsPaths.privateContact)
          .doc('contact')
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      debugPrint('Error reading private contact: $e');
      return null;
    }
  }

  /// Update request status ('on_the_way', 'in_progress', 'done').
  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection(FsPaths.requests).doc(requestId).update({
      'status': status,
      if (status == 'done') 'completedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Write live provider GPS coordinates: requests/{requestId}/live/provider.
  Future<void> updateLiveLocation({
    required String requestId,
    required double lat,
    required double lng,
  }) async {
    await _firestore
        .collection(FsPaths.requests)
        .doc(requestId)
        .collection(FsPaths.live)
        .doc('provider')
        .set({
      'lat': lat,
      'lng': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===========================================================================
  // PROFILE SUB-SCREENS (SERVICES, AREA, REVIEWS)
  // ===========================================================================

  /// Update provider services, experience, and 24x7 status.
  Future<void> updateServices({
    required String uid,
    required List<String> services,
    required int experienceYears,
    required bool open24x7,
  }) async {
    final existing = BrowseRepository.fetchListingByIdSync(uid);
    if (existing != null) {
      final updated = existing.copyWith(
        category: services.isNotEmpty ? services.first : 'Services',
        tags: services,
        open24x7: open24x7,
      );
      BrowseRepository.registerCustomListing(updated);
    }

    try {
      final batch = _firestore.batch();
      final providerRef = _firestore.collection(FsPaths.providers).doc(uid);
      batch.set(providerRef, {
        'services': services,
        'experienceYears': experienceYears,
      }, SetOptions(merge: true));

      final listingRef = _firestore.collection(FsPaths.listings).doc(uid);
      batch.set(listingRef, {
        'category': services.isNotEmpty ? services.first : 'Services',
        'tags': services,
        'open24x7': open24x7,
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      debugPrint('Firestore updateServices notice: $e');
    }
  }

  /// Update provider service radius and location.
  Future<void> updateServiceArea({
    required String uid,
    required double radiusKm,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final geoPoint = GeoPoint(lat, lng);
    final geohash = GeoFirePoint(GeoPoint(lat, lng)).geohash;

    final batch = _firestore.batch();
    final providerRef = _firestore.collection(FsPaths.providers).doc(uid);
    batch.update(providerRef, {
      'radiusKm': radiusKm,
      'serviceLocation': geoPoint,
      'address': address,
    });

    final listingRef = _firestore.collection(FsPaths.listings).doc(uid);
    batch.update(listingRef, {
      'location': geoPoint,
      'geohash': geohash,
      'address': address,
    });

    await batch.commit();
  }

  /// Stream reviews from listings/{uid}/reviews, newest first, limit 20.
  Stream<List<Review>> streamReviews(String uid) {
    return _firestore
        .collection(FsPaths.listings)
        .doc(uid)
        .collection(FsPaths.reviews)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Review.fromMap(doc.id, doc.data()))
          .toList();
      list.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return list;
    }).handleError((_) => <Review>[]);
  }
}

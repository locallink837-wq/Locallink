import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/models/listing.dart';

/// Vendor Data Repository (Module 7 - Shop and Place Owners).
/// All Firestore and Supabase operations for vendors live exclusively here.
class VendorRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  VendorRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  String? get currentUid => _auth.currentUser?.uid;

  /// Generate a new listing ID before starting the multi-step registration flow.
  String generateListingId() {
    return _firestore.collection(FsPaths.listings).doc().id;
  }

  /// Upload public listing photo to Supabase bucket 'listing-photos' at {uid}/{listingId}/{timestamp}.jpg.
  Future<String?> uploadListingPhoto({
    required String uid,
    required String listingId,
    required Uint8List bytes,
  }) async {
    try {
      final client = _supabase;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$uid/$listingId/$timestamp.jpg';

      if (client == null) {
        return 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?w=800';
      }

      await client.storage.from(Buckets.listingPhotos).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      return client.storage.from(Buckets.listingPhotos).getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading listing photo: $e');
      return null;
    }
  }

  /// Upload ownership proof photo to private bucket 'provider-docs' at {uid}/claim-{claimId}.jpg.
  Future<String?> uploadClaimProof({
    required String uid,
    required String claimId,
    required Uint8List bytes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.getIdToken(true);
      }

      final client = _supabase;
      final path = '$uid/claim-$claimId.jpg';

      if (client == null) {
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
      debugPrint('Error uploading claim proof: $e');
      return null;
    }
  }

  /// Fetch shop product chip tags from config/shopProducts (field 'items').
  Future<List<String>> fetchShopProductsConfig() async {
    try {
      final doc = await _firestore.collection(FsPaths.config).doc('shopProducts').get();
      if (!doc.exists || doc.data() == null) return [];
      final data = doc.data()!;
      if (!data.containsKey('items')) return [];
      final list = data['items'] as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('Error reading config/shopProducts: $e');
      return [];
    }
  }

  /// Submit Shop registration atomically in a single batch.
  Future<void> submitShopRegistration({
    required String listingId,
    required String uid,
    required String name,
    required String category,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool open24x7,
    required String opensAt,
    required String closesAt,
    required List<int> weeklyOff,
    required List<String> products,
    required String? photoUrl,
  }) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    final geoPoint = GeoPoint(latitude, longitude);
    final geohash = GeoFirePoint(geoPoint).geohash;

    // 1. listings/{id}
    final listingRef = _firestore.collection(FsPaths.listings).doc(listingId);
    batch.set(listingRef, {
      'kind': 'shop',
      'name': name,
      'category': category,
      'phone': phone,
      'address': address,
      'location': geoPoint,
      'geohash': geohash,
      'tags': products,
      'open24x7': open24x7,
      'opensAt': opensAt,
      'closesAt': closesAt,
      'weeklyOff': weeklyOff,
      'verified': true,
      'status': 'active',
      'photoUrls': photoUrl != null ? [photoUrl] : <String>[],
      'ratingSum': 0,
      'reviewCount': 0,
      'ownerId': uid,
      'createdAt': now,
    });

    // 2. users/{uid}
    final userRef = _firestore.collection(FsPaths.users).doc(uid);
    batch.set(
      userRef,
      {
        'role': 'shopOwner',
        'createdAt': now,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Submit Place registration atomically in a single batch.
  Future<void> submitPlaceRegistration({
    required String listingId,
    required String uid,
    required String name,
    required String category,
    required String categoryDetails,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool open24x7,
  }) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    final geoPoint = GeoPoint(latitude, longitude);
    final geohash = GeoFirePoint(geoPoint).geohash;

    // 1. listings/{id}
    final listingRef = _firestore.collection(FsPaths.listings).doc(listingId);
    batch.set(listingRef, {
      'kind': 'place',
      'name': name,
      'category': category,
      'highlight': categoryDetails,
      'phone': phone,
      'address': address,
      'location': geoPoint,
      'geohash': geohash,
      'tags': [category],
      'open24x7': open24x7,
      'verified': true,
      'status': 'active',
      'photoUrls': <String>[],
      'ratingSum': 0,
      'reviewCount': 0,
      'ownerId': uid,
      'createdAt': now,
    });

    // 2. users/{uid}
    final userRef = _firestore.collection(FsPaths.users).doc(uid);
    batch.set(
      userRef,
      {
        'role': 'placeOwner',
        'createdAt': now,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Search active listings with no owner (ownerId is empty) to claim.
  Future<List<Listing>> searchUnclaimedListings(String query) async {
    final snap = await _firestore
        .collection(FsPaths.listings)
        .where('ownerId', isEqualTo: '')
        .limit(20)
        .get();

    final list = snap.docs.map((d) => Listing.fromMap(d.id, d.data())).toList();
    if (query.trim().isEmpty) return list;

    final q = query.trim().toLowerCase();
    return list.where((l) => l.name.toLowerCase().contains(q) || l.category.toLowerCase().contains(q)).toList();
  }

  /// Create ownership claim document in claims/{id}.
  Future<void> submitClaim({
    required String listingId,
    required String claimantId,
    required String note,
    required String evidencePath,
  }) async {
    final claimRef = _firestore.collection(FsPaths.claims).doc();
    await claimRef.set({
      'listingId': listingId,
      'claimantId': claimantId,
      'note': note,
      'evidencePaths': [evidencePath],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream owner's listing document where ownerId == uid.
  Stream<Listing?> streamOwnerListing(String uid) {
    return _firestore
        .collection(FsPaths.listings)
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return Listing.fromMap(snap.docs.first.id, snap.docs.first.data());
    });
  }

  /// Stream views, calls, directions stats from listing_stats/{listingId}.
  Stream<Map<String, dynamic>?> streamListingStats(String listingId) {
    return _firestore.collection(FsPaths.listingStats).doc(listingId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return snap.data();
    });
  }

  /// Confirm listing info is correct (updates only lastConfirmedAt).
  Future<void> confirmListingInfo(String listingId) async {
    await _firestore.collection(FsPaths.listings).doc(listingId).update({
      'lastConfirmedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Edit only owner-editable fields (never status, verified, ratingSum, reviewCount).
  Future<void> updateListing({
    required String listingId,
    required String name,
    required String phone,
    required String opensAt,
    required String closesAt,
    required bool open24x7,
    required List<String> tags,
  }) async {
    await _firestore.collection(FsPaths.listings).doc(listingId).update({
      'name': name,
      'phone': phone,
      'opensAt': opensAt,
      'closesAt': closesAt,
      'open24x7': open24x7,
      'tags': tags,
    });
  }

  /// Stream listing status (pending, active, blocked) and rejectionReason.
  Stream<Map<String, dynamic>?> streamListingStatus(String listingId) {
    return _firestore.collection(FsPaths.listings).doc(listingId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return snap.data();
    });
  }
}

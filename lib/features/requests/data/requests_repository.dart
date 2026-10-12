import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/listing.dart';
import '../../../core/models/service_request.dart';

/// Customer Service Request Repository (Module 3 - Customer Service Requests).
/// All Firestore and Supabase operations for requests live exclusively here.
class RequestsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RequestsRepository({
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
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// Generate a new request ID.
  String generateRequestId() {
    return _firestore.collection(FsPaths.requests).doc().id;
  }

  /// Upload photo attachment to private bucket 'request-photos' at {uid}/{requestId}/{timestamp}.jpg.
  Future<String?> uploadRequestPhoto({
    required String uid,
    required String requestId,
    required Uint8List bytes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.getIdToken(true);
      }

      final client = _supabase;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$uid/$requestId/$timestamp.jpg';

      if (client == null) {
        return path;
      }

      await client.storage.from(Buckets.requestPhotos).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      return path;
    } catch (e) {
      debugPrint('Error uploading request photo: $e');
      return null;
    }
  }

  /// Submit new customer request in a single atomic batch:
  /// 1. requests/{id} (public info for matching)
  /// 2. requests/{id}/private/contact (sensitive unlocked phone and exact address)
  Future<void> createRequest({
    required String requestId,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String category,
    required String description,
    required List<String> photoUrls,
    required double latitude,
    required double longitude,
    required String roughAddress,
    required String exactAddress,
    required String urgency, // 'now' | 'today' | 'schedule' | 'sos'
  }) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    final geoPoint = GeoPoint(latitude, longitude);

    // 1. requests/{id}
    final reqRef = _firestore.collection(FsPaths.requests).doc(requestId);
    batch.set(reqRef, {
      'customerId': customerId,
      'customerName': customerName,
      'category': category,
      'description': description,
      'photoUrls': photoUrls,
      'location': geoPoint,
      'address': roughAddress,
      'urgency': urgency,
      'status': 'searching',
      'createdAt': now,
    });

    // 2. requests/{id}/private/contact
    final contactRef = _firestore
        .collection(FsPaths.requests)
        .doc(requestId)
        .collection(FsPaths.privateContact)
        .doc('contact');

    batch.set(contactRef, {
      'name': customerName,
      'phone': customerPhone,
      'address': exactAddress.isNotEmpty ? exactAddress : roughAddress,
      'createdAt': now,
    });

    await batch.commit();
  }

  /// Stream service request live to monitor status changes (searching, accepted, done, cancelled).
  Stream<ServiceRequest?> streamRequest(String requestId) {
    return _firestore.collection(FsPaths.requests).doc(requestId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ServiceRequest.fromMap(snap.id, snap.data()!);
    });
  }

  /// Cancel customer request with reason.
  Future<void> cancelRequest({
    required String requestId,
    required String reason,
  }) async {
    await _firestore.collection(FsPaths.requests).doc(requestId).update({
      'status': 'cancelled',
      'cancelReason': reason,
    });
  }

  /// Stream live GPS location of accepted provider: requests/{requestId}/live/provider.
  Stream<Map<String, dynamic>?> streamLiveProvider(String requestId) {
    return _firestore
        .collection(FsPaths.requests)
        .doc(requestId)
        .collection(FsPaths.live)
        .doc('provider')
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return snap.data();
    });
  }

  /// Stream chat messages: requests/{requestId}/messages.
  Stream<List<ChatMessage>> streamMessages(String requestId) {
    return _firestore
        .collection(FsPaths.requests)
        .doc(requestId)
        .collection(FsPaths.messages)
        .limit(50)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  /// Send message to chat: requests/{requestId}/messages.
  Future<void> sendMessage({
    required String requestId,
    required String senderId,
    required String text,
  }) async {
    await _firestore
        .collection(FsPaths.requests)
        .doc(requestId)
        .collection(FsPaths.messages)
        .add({
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Submit review to listings/{providerId}/reviews/{customerUid}.
  Future<void> submitReview({
    required String providerId,
    required String customerUid,
    required String customerName,
    required double rating,
    required String comment,
  }) async {
    final reviewRef = _firestore
        .collection(FsPaths.listings)
        .doc(providerId)
        .collection(FsPaths.reviews)
        .doc(customerUid);

    await reviewRef.set({
      'listingId': providerId,
      'authorId': customerUid,
      'authorName': customerName,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream all customer requests for history tabs (Active, Done, Cancelled), limit 20.
  Stream<List<ServiceRequest>> streamCustomerRequests(String customerId) {
    return _firestore
        .collection(FsPaths.requests)
        .where('customerId', isEqualTo: customerId)
        .limit(30)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => ServiceRequest.fromMap(d.id, d.data())).toList();
      list.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return list;
    });
  }

  /// Read provider public listing details.
  Future<Listing?> getProviderListing(String providerId) async {
    try {
      final doc = await _firestore.collection(FsPaths.listings).doc(providerId).get();
      if (!doc.exists || doc.data() == null) return null;
      return Listing.fromMap(doc.id, doc.data()!);
    } catch (_) {
      return null;
    }
  }
}

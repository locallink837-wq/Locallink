import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/models/app_user.dart';

/// Safety, SOS and Profile Data Repository (Module 5).
/// All Firestore and Supabase operations for safety, settings, and profile live exclusively here.
class SafetyProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SafetyProfileRepository({
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

  /// Fetch emergency numbers from config/emergency doc in Firestore.
  Future<List<Map<String, String>>> fetchEmergencyContacts() async {
    try {
      final doc = await _firestore.collection(FsPaths.config).doc('emergency').get();
      if (!doc.exists || doc.data() == null) {
        return _defaultEmergencyContacts();
      }
      final data = doc.data()!;
      final list = data['contacts'] as List<dynamic>?;
      if (list == null || list.isEmpty) return _defaultEmergencyContacts();

      return list
          .map((e) => {
                'label': (e['label'] ?? 'Emergency').toString(),
                'number': (e['number'] ?? '112').toString(),
              })
          .toList();
    } catch (_) {
      return _defaultEmergencyContacts();
    }
  }

  List<Map<String, String>> _defaultEmergencyContacts() {
    return [
      {'label': 'National Emergency', 'number': '112'},
      {'label': 'Police Helpline', 'number': '100'},
      {'label': 'Ambulance / Medical', 'number': '108'},
      {'label': 'Fire Department', 'number': '101'},
      {'label': 'Women Helpline', 'number': '1091'},
    ];
  }

  /// Log an SOS event in sos_events/{id}.
  Future<void> logSosEvent({double? lat, double? lng}) async {
    try {
      final ref = _firestore.collection(FsPaths.sosEvents).doc();
      await ref.set({
        'userId': _auth.currentUser?.uid ?? 'guest',
        if (lat != null && lng != null) 'location': GeoPoint(lat, lng),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Create an urgent SOS request.
  Future<String> createUrgentSosRequest({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String category,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final reqRef = _firestore.collection(FsPaths.requests).doc();
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    batch.set(reqRef, {
      'customerId': customerId,
      'customerName': customerName,
      'category': category,
      'description': 'EMERGENCY: Urgent assistance requested via SOS.',
      'photoUrls': <String>[],
      'location': GeoPoint(lat, lng),
      'address': address,
      'urgency': 'sos',
      'status': 'searching',
      'createdAt': now,
    });

    final contactRef = reqRef.collection(FsPaths.privateContact).doc('contact');
    batch.set(contactRef, {
      'name': customerName,
      'phone': customerPhone,
      'address': address,
      'createdAt': now,
    });

    await batch.commit();
    return reqRef.id;
  }

  /// Stream current user doc: users/{uid}.
  Stream<AppUser?> streamUser(String uid) {
    return _firestore.collection(FsPaths.users).doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AppUser.fromMap(snap.id, snap.data()!);
    }).handleError((_) => null);
  }

  /// Update user profile in users/{uid}.
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String area,
    required String language,
  }) async {
    await _firestore.collection(FsPaths.users).doc(uid).set({
      'name': name,
      'phone': phone,
      'area': area,
      'language': language,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Upload avatar to public bucket 'avatars' at {uid}/avatar.jpg.
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

      final url = client.storage.from(Buckets.avatars).getPublicUrl(path);
      await _firestore.collection(FsPaths.users).doc(uid).update({'photoUrl': url});
      return url;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  /// Update app settings in users/{uid}.settings.
  Future<void> updateSettings({
    required String uid,
    required Map<String, dynamic> settings,
    String? language,
  }) async {
    final data = <String, dynamic>{
      'settings': settings,
    };
    if (language != null) {
      data['language'] = language;
    }
    await _firestore.collection(FsPaths.users).doc(uid).set(data, SetOptions(merge: true));
  }

  /// Submit feedback to feedback/{id}.
  Future<void> submitFeedback({
    required String userId,
    required String message,
  }) async {
    await _firestore.collection(FsPaths.feedback).add({
      'userId': userId,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

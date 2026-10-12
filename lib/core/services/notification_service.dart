import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/firestore_paths.dart';

/// Firebase Cloud Messaging (FCM) Notification Service.
/// Manages device push tokens, permission prompts, and incoming message handlers.
class NotificationService {
  final FirebaseMessaging _fcm;
  final FirebaseFirestore _firestore;

  NotificationService({
    FirebaseMessaging? fcm,
    FirebaseFirestore? firestore,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Request user permission for push notifications
  Future<NotificationSettings?> requestPermission() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return null;
    }
  }

  /// Retrieve current FCM push token and optionally register in Firestore
  Future<String?> getDeviceToken({String? uid}) async {
    try {
      final token = await _fcm.getToken();
      if (token != null && uid != null && uid.isNotEmpty) {
        await saveTokenToFirestore(uid: uid, token: token);
      }
      return token;
    } catch (e) {
      debugPrint('Error retrieving FCM device token: $e');
      return null;
    }
  }

  /// Register FCM token under `users/{uid}/devices/{token}` in Firestore
  Future<void> saveTokenToFirestore({
    required String uid,
    required String token,
  }) async {
    try {
      await _firestore
          .collection(FsPaths.users)
          .doc(uid)
          .collection(FsPaths.devices)
          .doc(token)
          .set({
        'token': token,
        'platform': defaultTargetPlatform.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('Registered FCM token for user $uid');
    } catch (e) {
      debugPrint('Error saving device token: $e');
    }
  }

  /// Listen to incoming foreground push notifications
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  /// Hook for background message handler setup
  static void configureBackgroundHandler(BackgroundMessageHandler handler) {
    FirebaseMessaging.onBackgroundMessage(handler);
  }
}

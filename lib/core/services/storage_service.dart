import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../constants/firestore_paths.dart';

/// Supabase Storage Service for uploading images, avatars, documents, and attachments.
class StorageService {
  SupabaseClient? get _client {
    try {
      if (Env.supabaseUrl.isNotEmpty) {
        return Supabase.instance.client;
      }
    } catch (_) {}
    return null;
  }

  /// Upload byte data to a Supabase bucket and return public URL
  Future<String?> uploadBytes({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final client = _client;
      if (client == null) {
        debugPrint('Supabase client not initialized, returning local mock URI');
        return 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800';
      }

      await client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl = client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading to Supabase bucket $bucket: $e');
      return null;
    }
  }

  /// Convenience upload for listing photos
  Future<String?> uploadListingPhoto({
    required String listingId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = '$listingId/$fileName';
    return uploadBytes(
      bucket: Buckets.listingPhotos,
      path: path,
      bytes: bytes,
    );
  }

  /// Convenience upload for user profile avatars
  Future<String?> uploadAvatar({
    required String uid,
    required Uint8List bytes,
  }) async {
    final path = '$uid/avatar.jpg';
    return uploadBytes(
      bucket: Buckets.avatars,
      path: path,
      bytes: bytes,
    );
  }

  /// Convenience upload for service request attachments
  Future<String?> uploadRequestPhoto({
    required String requestId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = '$requestId/$fileName';
    return uploadBytes(
      bucket: Buckets.requestPhotos,
      path: path,
      bytes: bytes,
    );
  }

  /// Convenience upload for provider verification documents (ID proof, selfie)
  Future<String?> uploadProviderDocument({
    required String providerUid,
    required Uint8List bytes,
    required String docType,
  }) async {
    final path = '$providerUid/$docType.jpg';
    return uploadBytes(
      bucket: Buckets.providerDocs,
      path: path,
      bytes: bytes,
    );
  }
}

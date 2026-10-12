import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Image picking and compression constraints.
/// Requirements: image_picker maxWidth 1280, imageQuality 70, max 5 MB per file.
const double kImageMaxWidth = 1280.0;
const double kImageMaxHeight = 1280.0;
const int kImageQuality = 70;
const int kMaxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from device gallery with target compression constraints
  static Future<XFile?> pickFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: kImageMaxWidth,
        maxHeight: kImageMaxHeight,
        imageQuality: kImageQuality,
      );
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Capture a new photo with camera with target compression constraints
  static Future<XFile?> pickFromCamera() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: kImageMaxWidth,
        maxHeight: kImageMaxHeight,
        imageQuality: kImageQuality,
      );
    } catch (e) {
      debugPrint('Error capturing photo from camera: $e');
      return null;
    }
  }

  /// Verify if byte array or file size meets the 5MB limit
  static bool isUnderSizeLimit(int bytesLength) {
    return bytesLength <= kMaxFileSizeBytes;
  }
}

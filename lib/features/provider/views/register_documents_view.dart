import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';
import 'pending_view.dart';

/// Screen 6.4: Provider Registration Step 4 - Verification Documents.
/// Uploads ID Proof and Selfie securely to Supabase Storage, and commits registration atomically.
class RegisterDocumentsView extends StatefulWidget {
  const RegisterDocumentsView({super.key});

  static const route = '/provider/register-documents';

  @override
  State<RegisterDocumentsView> createState() => _RegisterDocumentsViewState();
}

class _RegisterDocumentsViewState extends State<RegisterDocumentsView> {
  final _picker = ImagePicker();
  final _repo = ProviderRepository();

  File? _idProofFile;
  File? _selfieFile;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Pick image using ImagePicker with 1280 max width and 70 quality (< 5MB)
  Future<void> _pickImage({required bool isIdProof, required ImageSource source}) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 70,
      );

      if (picked != null) {
        final file = File(picked.path);
        // Ensure file size is below 5 MB
        final sizeBytes = await file.length();
        if (sizeBytes > 5 * 1024 * 1024) {
          if (!mounted) return;
          setState(() => _errorMessage = 'Image size must be less than 5 MB');
          return;
        }

        if (!mounted) return;
        setState(() {
          if (isIdProof) {
            _idProofFile = file;
          } else {
            _selfieFile = file;
          }
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not select photo: $e');
    }
  }

  void _showPickerSheet({required bool isIdProof}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: UiColors.indigo),
              title: uiText('Take Photo with Camera', size: 14, weight: FontWeight.w700),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(isIdProof: isIdProof, source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: UiColors.indigo),
              title: uiText('Choose from Gallery', size: 14, weight: FontWeight.w700),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(isIdProof: isIdProof, source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (_idProofFile == null) {
      setState(() => _errorMessage = 'Please upload a photo of your ID proof (Aadhaar / Voter ID / PAN)');
      return;
    }
    if (_selfieFile == null) {
      setState(() => _errorMessage = 'Please take a clear selfie for identity verification');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      setState(() => _errorMessage = 'You must be logged in with a real account to register as a provider.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final uid = user.uid;
      final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};

      // 1. Upload ID Proof to Supabase provider-docs
      final idBytes = await _idProofFile!.readAsBytes();
      final idProofPath = await _repo.uploadDocument(
        uid: uid,
        bytes: idBytes,
        docType: 'id-proof',
      );

      if (idProofPath == null) {
        throw Exception('Failed to upload ID proof. Please try again.');
      }

      // 2. Upload Selfie to Supabase provider-docs
      final selfieBytes = await _selfieFile!.readAsBytes();
      final selfiePath = await _repo.uploadDocument(
        uid: uid,
        bytes: selfieBytes,
        docType: 'selfie',
      );

      if (selfiePath == null) {
        throw Exception('Failed to upload Selfie. Please try again.');
      }

      // 3. Commit atomic batch write
      await _repo.submitRegistration(
        uid: uid,
        name: (args['name'] ?? 'Provider').toString(),
        businessName: (args['businessName'] ?? '').toString(),
        phone: (args['phone'] ?? '').toString(),
        services: List<String>.from(args['services'] ?? ['Services']),
        experienceYears: (args['experienceYears'] ?? 1) as int,
        radiusKm: (args['radiusKm'] ?? 5.0) as double,
        languages: List<String>.from(args['languages'] ?? ['English']),
        open24x7: (args['open24x7'] ?? false) as bool,
        latitude: (args['latitude'] ?? 18.5204) as double,
        longitude: (args['longitude'] ?? 73.8567) as double,
        address: (args['address'] ?? '').toString(),
        idProofPath: idProofPath,
        selfiePath: selfiePath,
      );

      if (!mounted) return;
      // Navigate to pending verification screen
      Navigator.pushNamedAndRemoveUntil(context, PendingView.route, (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Registration error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Register (4 of 4)',
        bottomButton: UiMainButton(
          label: 'Submit for verification',
          isLoading: _isSubmitting,
          onPressed: _onSubmit,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper (4 of 4)
              const UiStepper(
                totalSteps: 4,
                currentStep: 4,
                stepLabels: ['Core', 'Details', 'Area', 'Docs'],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              // Upload ID Proof Card
              uiText('1. Government ID Proof', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 4),
              uiText('Aadhaar Card, Voter Card, Driving License, or PAN', size: 11.5, color: UiColors.muted),
              const SizedBox(height: 8),
              UiUploadCard(
                label: _idProofFile != null ? 'ID Photo selected' : 'Upload ID Proof',
                pickedFile: _idProofFile,
                icon: Icons.badge_outlined,
                onTap: () => _showPickerSheet(isIdProof: true),
              ),
              const SizedBox(height: 20),

              // Upload Selfie Card
              uiText('2. Live Selfie', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 4),
              uiText('Take a clear front-facing photo of your face', size: 11.5, color: UiColors.muted),
              const SizedBox(height: 8),
              UiUploadCard(
                label: _selfieFile != null ? 'Selfie selected' : 'Take Selfie',
                pickedFile: _selfieFile,
                icon: Icons.face_rounded,
                onTap: () => _showPickerSheet(isIdProof: false),
              ),
              const SizedBox(height: 16),

              // Privacy tag note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UiColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 20, color: UiColors.indigo),
                    const SizedBox(width: 10),
                    Expanded(
                      child: uiText(
                        'Stored privately. Your identity documents are encrypted and never shown publicly.',
                        size: 11.5,
                        color: UiColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/assistant_repository.dart';
import 'ai_result_view.dart';
import 'ai_unavailable_view.dart';

/// Screen 4.2: Photo Capture and User Consent.
/// Captures photo via camera or gallery, explains privacy terms, and executes Gemini analysis.
class PhotoConsentView extends StatefulWidget {
  const PhotoConsentView({super.key});

  static const route = '/assistant/photo-consent';

  @override
  State<PhotoConsentView> createState() => _PhotoConsentViewState();
}

class _PhotoConsentViewState extends State<PhotoConsentView> {
  final _promptController = TextEditingController();
  final _picker = ImagePicker();
  final _repo = AssistantRepository();

  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not access camera/gallery: $e');
    }
  }

  Future<void> _analyzePhoto() async {
    if (_selectedImage == null) {
      setState(() => _errorMessage = 'Please take or choose a photo of the broken item.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final session = await _repo.diagnoseIssue(
        photoBytes: bytes,
        userPrompt: _promptController.text.trim(),
        mimeType: 'image/jpeg',
      );

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      Navigator.pushReplacementNamed(
        context,
        AiResultView.route,
        arguments: {'session': session},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      Navigator.pushNamed(context, AiUnavailableView.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Diagnose Problem',
        bottomButton: UiMainButton(
          label: _isAnalyzing ? 'Analyzing with AI...' : 'Analyze with Gemini AI',
          isLoading: _isAnalyzing,
          customAccent: UiColors.teal,
          onPressed: _isAnalyzing ? () {} : _analyzePhoto,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uiText('Visual Diagnostic Assistant', size: 18, weight: FontWeight.w800),
              const SizedBox(height: 6),
              uiText(
                'Photograph the issue clearly (faucet, switchboard, water heater, lock, etc.).',
                size: 13.5,
                color: UiColors.muted,
                height: 1.4,
              ),
              const SizedBox(height: 18),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 16),
              ],

              // Image Picker Box or Preview
              if (_selectedImage == null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: UiColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: UiColors.line, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera_back_outlined, size: 48, color: UiColors.muted.withValues(alpha: 0.6)),
                      const SizedBox(height: 12),
                      uiText('No photo selected yet', size: 14, weight: FontWeight.w600, color: UiColors.muted),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UiColors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Camera', style: TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: () => _pickImage(ImageSource.camera),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: UiColors.teal,
                              side: const BorderSide(color: UiColors.teal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Optional problem description
              UiTextInput(
                label: 'What seems to be wrong? (Optional)',
                hintText: 'e.g. Water is leaking continuously from the lower brass ring',
                controller: _promptController,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Privacy & Consent Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: UiColors.teal.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UiColors.teal.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.privacy_tip_outlined, color: UiColors.teal, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          uiText('Data Privacy & Processing', size: 12.5, weight: FontWeight.w700, color: UiColors.teal),
                          const SizedBox(height: 3),
                          uiText(
                            'Your image is analyzed using Gemini Vision solely to detect repair requirements and recommend local trade professionals. It is stored securely in your private vault.',
                            size: 11.5,
                            color: UiColors.muted,
                            height: 1.4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

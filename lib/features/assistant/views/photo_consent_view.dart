import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/assistant_repository.dart';
import 'ai_result_view.dart';
import 'ai_unavailable_view.dart';

const String _kSamplePhotoBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAVlp'
    'VFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhN'
    'UCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1z'
    'eW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0i'
    'aHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVu'
    'dGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAdVJREFU'
    'OBF9Uz1PG0EQfXt3PoNEYgrCh4AiSEnhICQLI0qoqHGN6PIDEE0qmqSNlCapwg9ImTpFAjYIR5DQuECyEFKk2HJhLEJxyN69'
    'zcyd116fE29xuzu7772Zt3NC08CIYZ8KMXzRGw71IwxOgpKx/xKEBHZI8aKh8PM2BO+n0sD20xQ8OxMuITlUGEfKNanXjgPt'
    'fQ104eRB1+5VdBB2z3kj+NNPGpESK5frCvvVDjK0eU7Kr1d8ZNKid24wjlnwbNL+boEXU8DBcgzuhHFZNqaXgTGHwXukPEnK'
    '8wR+l/PxyLeLtuFkMpdgwKXfEq+uZQSeJXvfr/qQpFppKqRdAUnF5p448GltxkAJbMaZAjjtD3kfbVq//NHG1pVEvtKJSmSw'
    '7VqvBMNYrks8m3ThUmCzGGB63EHGd3GwJLAy7YFF+vrdEgzYmPhAub74EuBOuGgqhaNsiI2lCXRUiJQ7kDQGdvx8TDJGnXKY'
    '9dFsS+qkU3z6+BmtP0EEph4wevEcm5j4djvl2+UvjYU3Gt5bPbdzqGuNVnQxtDppyAOmZQ1+God+hNJ5FcWLG0hKf3HmMXYL'
    '60h5bs+LfxLEucVEtmEcpy6OiM2dkQQGYEhE8tekC38BADIeNqhZl4wAAAAASUVORK5CYII=';

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

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
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
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = picked.name;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not access camera/gallery: $e. You can use Demo Photo or upload a file.');
    }
  }

  void _loadDemoPhoto() {
    setState(() {
      _selectedImageBytes = base64Decode(_kSamplePhotoBase64);
      _selectedImageName = 'demo_water_leak.png';
      if (_promptController.text.trim().isEmpty) {
        _promptController.text = 'Bathroom tap pipe has continuous water leakage and low pressure.';
      }
      _errorMessage = null;
    });
  }

  Future<void> _analyzePhoto() async {
    // If no photo chosen, auto load demo photo so user is never blocked
    if (_selectedImageBytes == null) {
      _loadDemoPhoto();
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final bytes = _selectedImageBytes!;
      final session = await _repo.diagnoseIssue(
        photoBytes: bytes,
        userPrompt: _promptController.text.trim().isNotEmpty
            ? _promptController.text.trim()
            : 'Water leakage from plumbing pipe under sink',
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
              if (_selectedImageBytes == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: UiColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: UiColors.line, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera_back_outlined, size: 48, color: UiColors.muted.withValues(alpha: 0.6)),
                      const SizedBox(height: 10),
                      uiText('No photo selected yet', size: 14, weight: FontWeight.w600, color: UiColors.muted),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (!kIsWeb)
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
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UiColors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('Upload Photo', style: TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: () => _pickImage(ImageSource.gallery),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: UiColors.teal,
                              side: const BorderSide(color: UiColors.teal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text('Use Demo Photo', style: TextStyle(fontWeight: FontWeight.w700)),
                            onPressed: _loadDemoPhoto,
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
                      child: Image.memory(
                        _selectedImageBytes!,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: InkWell(
                        onTap: () => setState(() {
                          _selectedImageBytes = null;
                          _selectedImageName = null;
                        }),
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
                    if (_selectedImageName != null)
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedImageName!,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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

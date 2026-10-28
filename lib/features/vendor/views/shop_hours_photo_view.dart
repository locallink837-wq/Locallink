import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/vendor_repository.dart';
import 'product_types_view.dart';

/// Screen 7.3: Shop Hours and Photo (3 of 3).
/// Collects operating schedule, 24x7 status, and uploads storefront photo.
class ShopHoursPhotoView extends StatefulWidget {
  const ShopHoursPhotoView({super.key});

  static const route = '/vendor/shop-hours-photo';

  @override
  State<ShopHoursPhotoView> createState() => _ShopHoursPhotoViewState();
}

class _ShopHoursPhotoViewState extends State<ShopHoursPhotoView> {
  final _opensAtController = TextEditingController(text: '09:00');
  final _closesAtController = TextEditingController(text: '21:00');
  final _repo = VendorRepository();
  final _picker = ImagePicker();

  bool _open24x7 = false;
  File? _pickedPhoto;
  Uint8List? _photoBytes;
  bool _isUploading = false;
  String? _uploadedPhotoUrl;
  String? _errorMessage;

  @override
  void dispose() {
    _opensAtController.dispose();
    _closesAtController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 70,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _photoBytes = bytes;
          _pickedPhoto = File(picked.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to select photo: $e');
    }
  }

  void _enterImageUrl() async {
    final controller = TextEditingController(text: _uploadedPhotoUrl ?? '');
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: uiText('Enter Image URL', size: 16, weight: FontWeight.w700),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/shop.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('OK')),
        ],
      ),
    );
    if (url != null && url.isNotEmpty) {
      setState(() {
        _uploadedPhotoUrl = url;
      });
    }
  }

  Future<void> _onNext() async {
    final prevArgs = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final listingId = prevArgs['listingId'] as String? ?? _repo.generateListingId();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (uid.isEmpty) {
      setState(() => _errorMessage = 'Please sign in to register your shop.');
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      if (_photoBytes != null) {
        final url = await _repo.uploadListingPhoto(
          uid: uid,
          listingId: listingId,
          bytes: _photoBytes!,
        );
        if (url != null) _uploadedPhotoUrl = url;
      }

      if (!mounted) return;
      setState(() => _isUploading = false);

      final combinedData = Map<String, dynamic>.from(prevArgs)
        ..addAll({
          'open24x7': _open24x7,
          'opensAt': _opensAtController.text.trim(),
          'closesAt': _closesAtController.text.trim(),
          'weeklyOff': <int>[7], // Sunday off by default
          'photoUrl': _uploadedPhotoUrl,
        });

      Navigator.pushNamed(context, ProductTypesView.route, arguments: combinedData);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _errorMessage = 'Error preparing shop data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: UiScaffold(
        title: 'Hours and photo (3 of 3)',
        bottomButton: UiMainButton(
          label: 'Continue to products',
          customAccent: UiColors.amber,
          isLoading: _isUploading,
          onPressed: _onNext,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UiStepper(
                totalSteps: 3,
                currentStep: 3,
                customAccent: UiColors.amber,
                stepLabels: ['Shop info', 'Location', 'Hours & photo'],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              // 24 Hours toggle card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: UiColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          uiText('Open 24 hours', size: 13.5, weight: FontWeight.w700),
                          const SizedBox(height: 2),
                          uiText('Keep listing active around the clock', size: 11.5, color: UiColors.muted),
                        ],
                      ),
                    ),
                    Switch(
                      value: _open24x7,
                      activeThumbColor: UiColors.amber,
                      onChanged: (val) => setState(() => _open24x7 = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (!_open24x7) ...[
                Row(
                  children: [
                    Expanded(
                      child: UiTextInput(
                        label: 'Opens at',
                        hintText: '09:00',
                        controller: _opensAtController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: UiTextInput(
                        label: 'Closes at',
                        hintText: '21:00',
                        controller: _closesAtController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              uiText('Storefront Photo', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 4),
              uiText('Helps nearby customers easily recognize your shop', size: 11.5, color: UiColors.muted),
              const SizedBox(height: 8),

              UiUploadCard(
                label: (_uploadedPhotoUrl != null || _photoBytes != null)
                    ? 'Shop photo selected'
                    : 'Add shop photo (Gallery or URL)',
                pickedBytes: _photoBytes,
                imageUrl: _uploadedPhotoUrl,
                icon: Icons.storefront_outlined,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo_library_outlined),
                            title: const Text('Choose from Gallery'),
                            onTap: () {
                              Navigator.pop(ctx);
                              _pickPhoto();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.link_rounded),
                            title: const Text('Enter Image URL (Image.network)'),
                            onTap: () {
                              Navigator.pop(ctx);
                              _enterImageUrl();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

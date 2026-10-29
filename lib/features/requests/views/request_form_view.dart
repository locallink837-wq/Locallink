import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/enums.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/requests_repository.dart';
import 'finding_providers_view.dart';

/// Screen 3.2: Service Request Form.
/// Collects problem description, optional photo attachment, urgency (Normal vs Urgent), and address.
class RequestFormView extends StatefulWidget {
  const RequestFormView({super.key});

  static const route = '/requests/request-form';

  @override
  State<RequestFormView> createState() => _RequestFormViewState();
}

class _RequestFormViewState extends State<RequestFormView> {
  final _descController = TextEditingController();
  late final TextEditingController _addressController;
  final _repo = RequestsRepository();
  final _picker = ImagePicker();

  String _category = 'Plumber';
  Urgency _urgency = Urgency.now;
  Uint8List? _photoBytes;
  String? _photoUrl;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: LocationService.lastKnownArea ?? 'Shivajinagar, Pune',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    if (args.containsKey('category')) {
      _category = args['category'].toString();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _addressController.dispose();
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
          _photoUrl = null;
        });
      }
    } catch (_) {}
  }

  void _enterImageUrl() async {
    final controller = TextEditingController(text: _photoUrl ?? '');
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: uiText('Enter Image URL', size: 16, weight: FontWeight.w700),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/photo.jpg',
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
        _photoUrl = url;
        _photoBytes = null;
      });
    }
  }

  Future<void> _sendRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    // Gated for anonymous guests
    if (user == null || user.isAnonymous) {
      Navigator.pushNamed(context, '/auth/login-to-book');
      return;
    }

    final desc = _descController.text.trim();
    final address = _addressController.text.trim();

    if (desc.isEmpty) {
      setState(() => _errorMessage = 'Please describe the problem you need help with.');
      return;
    }
    if (address.isEmpty) {
      setState(() => _errorMessage = 'Please provide your service address.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final requestId = _repo.generateRequestId();
      final photoUrls = <String>[];

      if (_photoUrl != null && _photoUrl!.isNotEmpty) {
        photoUrls.add(_photoUrl!);
      } else if (_photoBytes != null) {
        final path = await _repo.uploadRequestPhoto(
          uid: user.uid,
          requestId: requestId,
          bytes: _photoBytes!,
        );
        if (path != null) photoUrls.add(path);
      }

      final lat = LocationService.lastKnownDevicePosition?.latitude ?? 18.5204;
      final lng = LocationService.lastKnownDevicePosition?.longitude ?? 73.8567;

      await _repo.createRequest(
        requestId: requestId,
        customerId: user.uid,
        customerName: user.displayName ?? 'Customer',
        customerPhone: user.phoneNumber ?? '+91 98765 43210',
        category: _category,
        description: desc,
        photoUrls: photoUrls,
        latitude: lat,
        longitude: lng,
        roughAddress: address,
        exactAddress: address,
        urgency: _urgency == Urgency.sos ? 'sos' : 'now',
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        FindingProvidersView.route,
        arguments: {'requestId': requestId, 'category': _category},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Could not create request: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Request a $_category',
        bottomButton: UiMainButton(
          label: 'Send request',
          customAccent: UiColors.teal,
          isLoading: _isSubmitting,
          onPressed: _sendRequest,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              UiTextInput(
                label: 'What is the problem?',
                hintText: 'e.g. Water leak from kitchen tap, urgent repair needed',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              uiText('Add photo (optional)', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 8),
              UiUploadCard(
                label: (_photoUrl != null || _photoBytes != null)
                    ? 'Photo attached'
                    : 'Upload photo (Gallery or URL)',
                pickedBytes: _photoBytes,
                imageUrl: _photoUrl,
                icon: Icons.add_a_photo_outlined,
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
              const SizedBox(height: 18),

              uiText('Urgency level', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: UiChip(
                      label: 'Normal / Today',
                      customAccent: UiColors.teal,
                      isSelected: _urgency == Urgency.now,
                      onTap: () => setState(() => _urgency = Urgency.now),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: UiChip(
                      label: 'Urgent / Immediate',
                      customAccent: UiColors.red,
                      isSelected: _urgency == Urgency.sos,
                      onTap: () => setState(() => _urgency = Urgency.sos),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              UiTextInput(
                label: 'Address and pin',
                hintText: 'e.g. Flat 301, Lakeview Apts, Kothrud',
                controller: _addressController,
                maxLines: 2,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

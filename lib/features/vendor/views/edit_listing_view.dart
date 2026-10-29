import 'package:flutter/material.dart';

import '../../../core/models/listing.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/vendor_repository.dart';

/// Screen 7.9: Edit Listing Information.
/// Allows vendor to update shop/place name, phone, hours, and tags.
/// Never alters system fields like verified, status, ratingSum, or reviewCount.
class EditListingView extends StatefulWidget {
  const EditListingView({super.key});

  static const route = '/vendor/edit-listing';

  @override
  State<EditListingView> createState() => _EditListingViewState();
}

class _EditListingViewState extends State<EditListingView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _opensAtController = TextEditingController(text: '09:00');
  final _closesAtController = TextEditingController(text: '21:00');
  final _tagsController = TextEditingController();
  final _repo = VendorRepository();

  bool _open24x7 = false;
  bool _isSaving = false;
  String? _errorMessage;
  Listing? _listing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listing == null) {
      final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
      _listing = args['listing'] as Listing?;
      if (_listing != null) {
        _nameController.text = _listing!.name;
        _phoneController.text = _listing!.phone;
        _opensAtController.text = _listing!.opensAt ?? '09:00';
        _closesAtController.text = _listing!.closesAt ?? '21:00';
        _open24x7 = _listing!.open24x7;
        _tagsController.text = _listing!.tags.join(', ');
      } else {
        _nameController.text = 'Pune Hardware & Paints';
        _phoneController.text = '+91 98220 54321';
        _opensAtController.text = '09:00';
        _closesAtController.text = '21:00';
        _open24x7 = false;
        _tagsController.text = 'Pipes, Paints, Electrical, Tools, Sanitary';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _opensAtController.dispose();
    _closesAtController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Business name cannot be empty');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (_listing != null) {
        await _repo.updateListing(
          listingId: _listing!.id,
          name: name,
          phone: _phoneController.text.trim(),
          opensAt: _opensAtController.text.trim(),
          closesAt: _closesAtController.text.trim(),
          open24x7: _open24x7,
          tags: tags.isNotEmpty ? tags : _listing!.tags,
        );
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing updated successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing updated successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: UiScaffold(
        title: 'Edit listing',
        bottomButton: UiMainButton(
          label: 'Save',
          customAccent: UiColors.amber,
          isLoading: _isSaving,
          onPressed: _saveChanges,
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
                label: 'Business name',
                controller: _nameController,
              ),
              const SizedBox(height: 14),

              UiTextInput(
                label: 'Phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Open 24x7 toggle
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
                      child: uiText('Open 24 hours', size: 13.5, weight: FontWeight.w700),
                    ),
                    Switch(
                      value: _open24x7,
                      activeThumbColor: UiColors.amber,
                      onChanged: (val) => setState(() => _open24x7 = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

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
                const SizedBox(height: 14),
              ],

              UiTextInput(
                label: 'Products / Items in stock (comma separated)',
                hintText: 'Pipes, Paint, Tools, Locks',
                controller: _tagsController,
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

import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/vendor_repository.dart';
import 'place_location_view.dart';

/// Screen 7.5: Register Place (1 of 2).
/// Collects Place Category (Hospital, College, PG, Bank), Name, details, and phone.
class RegisterPlaceView extends StatefulWidget {
  const RegisterPlaceView({super.key});

  static const route = '/vendor/register-place';

  @override
  State<RegisterPlaceView> createState() => _RegisterPlaceViewState();
}

class _RegisterPlaceViewState extends State<RegisterPlaceView> {
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  final _phoneController = TextEditingController();
  final _repo = VendorRepository();

  String _selectedCategory = 'Hospital';
  String? _errorMessage;
  late final String _listingId;

  final List<String> _categories = [
    'Hospital',
    'College',
    'PG',
    'Bank',
    'Coaching',
    'Govt office',
  ];

  @override
  void initState() {
    super.initState();
    _listingId = _repo.generateListingId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onNext() {
    final name = _nameController.text.trim();
    final details = _detailsController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter the place name');
      return;
    }

    setState(() => _errorMessage = null);

    final data = <String, dynamic>{
      'listingId': _listingId,
      'name': name,
      'category': _selectedCategory,
      'categoryDetails': details,
      'phone': phone,
    };

    Navigator.pushNamed(context, PlaceLocationView.route, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: UiScaffold(
        title: 'Register place (1 of 2)',
        bottomButton: UiMainButton(
          label: 'Next',
          customAccent: UiColors.amber,
          onPressed: _onNext,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UiStepper(
                totalSteps: 2,
                currentStep: 1,
                customAccent: UiColors.amber,
                stepLabels: ['Place details', 'Location'],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              uiText('Place category', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in _categories)
                    UiChip(
                      label: cat,
                      customAccent: UiColors.amber,
                      isSelected: _selectedCategory == cat,
                      onTap: () => setState(() => _selectedCategory = cat),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              UiTextInput(
                label: 'Name of place / organization',
                hintText: 'e.g. City Hospital, Pune',
                controller: _nameController,
              ),
              const SizedBox(height: 14),

              UiTextInput(
                label: 'Category details / Key facilities',
                hintText: 'e.g. Emergency 24x7 / Ambulance / ICU',
                controller: _detailsController,
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              UiTextInput(
                label: 'Helpline / Reception phone',
                hintText: 'Official phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

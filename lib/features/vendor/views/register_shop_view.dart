import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/vendor_repository.dart';
import 'shop_location_view.dart';

/// Screen 7.1: Register Shop (1 of 3).
/// Collects shop name, category, and phone number.
class RegisterShopView extends StatefulWidget {
  const RegisterShopView({super.key});

  static const route = '/vendor/register-shop';

  @override
  State<RegisterShopView> createState() => _RegisterShopViewState();
}

class _RegisterShopViewState extends State<RegisterShopView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _repo = VendorRepository();

  String _selectedCategory = 'Hardware';
  String? _errorMessage;
  late final String _listingId;

  final List<String> _categories = [
    'Hardware',
    'Grocery',
    'Stationers',
    'Electronics',
    'Furniture',
    'Medical',
  ];

  @override
  void initState() {
    super.initState();
    _listingId = _repo.generateListingId();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      _phoneController.text = user.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onNext() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your shop name');
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid 10-digit phone number');
      return;
    }

    setState(() => _errorMessage = null);

    final data = <String, dynamic>{
      'listingId': _listingId,
      'name': name,
      'category': _selectedCategory,
      'phone': phone,
    };

    Navigator.pushNamed(context, ShopLocationView.route, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: UiScaffold(
        title: 'Register shop (1 of 3)',
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
                totalSteps: 3,
                currentStep: 1,
                customAccent: UiColors.amber,
                stepLabels: ['Shop info', 'Location', 'Hours & photo'],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              UiTextInput(
                label: 'Shop name',
                hintText: 'e.g. Sharma Hardware',
                controller: _nameController,
              ),
              const SizedBox(height: 16),

              uiText('Category', size: 13.5, weight: FontWeight.w600, color: UiColors.muted),
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
                label: 'Contact phone',
                hintText: '10-digit mobile number',
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

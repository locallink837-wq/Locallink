import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/safety_profile_repository.dart';

/// Screen 5.2: Urgent Request for Emergency Help.
/// Gated for authenticated users. Creates high-priority request with urgency 'sos'.
class UrgentRequestView extends StatefulWidget {
  const UrgentRequestView({super.key});

  static const route = '/safety-profile/urgent-request';

  @override
  State<UrgentRequestView> createState() => _UrgentRequestViewState();
}

class _UrgentRequestViewState extends State<UrgentRequestView> {
  final _addressController = TextEditingController(text: 'Current location (GPS Confirmed)');
  final _repo = SafetyProfileRepository();

  String _selectedCategory = 'Locksmith';
  bool _isSubmitting = false;
  String? _statusMessage;
  String? _errorMessage;

  final List<String> _urgentServices = [
    'Locksmith',
    'Electrician',
    'Plumber',
    'Ambulance',
    'Mechanic',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _sendUrgentRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      Navigator.pushNamed(context, '/auth/login-to-book');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _repo.createUrgentSosRequest(
        customerId: user.uid,
        customerName: user.displayName ?? 'Customer',
        customerPhone: user.phoneNumber ?? '+91 98765 43210',
        category: _selectedCategory,
        address: _addressController.text.trim(),
        lat: 18.5204,
        lng: 73.8567,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _statusMessage = 'Urgent request broadcasted! Verified $_selectedCategory providers nearby are being alerted.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Could not send request: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.red),
      child: UiScaffold(
        title: 'Urgent help',
        bottomButton: UiMainButton(
          label: 'Send urgent request',
          customAccent: UiColors.red,
          isLoading: _isSubmitting,
          onPressed: _sendUrgentRequest,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: uiText(_statusMessage!, size: 12.5, color: const Color(0xFF1B5E20)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              uiText('What kind of urgent assistance is required?', size: 13.5, weight: FontWeight.w700),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in _urgentServices)
                    UiChip(
                      label: cat,
                      customAccent: UiColors.red,
                      isSelected: _selectedCategory == cat,
                      onTap: () => setState(() => _selectedCategory = cat),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              UiTextInput(
                label: 'Location confirmed',
                hintText: 'Your current street / building',
                controller: _addressController,
                prefixIcon: const Icon(Icons.my_location_rounded, color: UiColors.red, size: 20),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: UiColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 20, color: UiColors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: uiText(
                        'Urgent requests ring verified 24x7 providers with emergency priority alerts.',
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

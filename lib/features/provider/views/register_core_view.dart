import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';
import 'register_details_view.dart';

/// Screen 6.1: Provider Registration Step 1 - Core Information.
/// Collects Provider Name, Business Name, Primary Services, and Phone.
class RegisterCoreView extends StatefulWidget {
  const RegisterCoreView({super.key});

  static const route = '/provider/register-core';

  @override
  State<RegisterCoreView> createState() => _RegisterCoreViewState();
}

class _RegisterCoreViewState extends State<RegisterCoreView> {
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _phoneController = TextEditingController();
  final _repo = ProviderRepository();

  List<String> _availableServices = [];
  final Set<String> _selectedServices = {};
  bool _isLoadingCategories = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Pre-fill phone from auth if user is signed in with phone/google
  void _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      _phoneController.text = user.phoneNumber!;
    }

    try {
      final services = await _repo.fetchServiceCategories();
      if (!mounted) return;
      setState(() {
        _availableServices = services.isNotEmpty
            ? services
            : ['Plumber', 'Electrician', 'Carpenter', 'Locksmith', 'Cleaning', 'Appliance Repair'];
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _availableServices = ['Plumber', 'Electrician', 'Carpenter', 'Locksmith'];
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onNext() {
    final name = _nameController.text.trim();
    final business = _businessController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your personal name');
      return;
    }
    if (_selectedServices.isEmpty) {
      setState(() => _errorMessage = 'Please select at least one service');
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid 10-digit phone number');
      return;
    }

    setState(() => _errorMessage = null);

    // Pass data forward in route arguments map
    final data = <String, dynamic>{
      'name': name,
      'businessName': business.isNotEmpty ? business : name,
      'services': _selectedServices.toList(),
      'phone': phone,
    };

    Navigator.pushNamed(context, RegisterDetailsView.route, arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Register (1 of 3)',
        bottomButton: UiMainButton(
          label: 'Next',
          onPressed: _onNext,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper indicator (1 of 3)
              const UiStepper(
                totalSteps: 3,
                currentStep: 1,
                stepLabels: ['Core', 'Details', 'Location'],
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                UiWarningBanner(text: _errorMessage!),
                const SizedBox(height: 14),
              ],

              // Full Name input
              UiTextInput(
                label: 'Your name',
                hintText: 'e.g. Ramesh Kumar',
                controller: _nameController,
              ),
              const SizedBox(height: 14),

              // Business Name input
              UiTextInput(
                label: 'Business name',
                hintText: 'e.g. Ramesh Plumbing Works (optional)',
                controller: _businessController,
              ),
              const SizedBox(height: 16),

              // Services selection chips
              uiText('Services offered', size: 13.5, weight: FontWeight.w600, color: UiColors.muted),
              const SizedBox(height: 8),

              if (_isLoadingCategories)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final service in _availableServices)
                      UiChip(
                        label: service,
                        isSelected: _selectedServices.contains(service),
                        onTap: () {
                          setState(() {
                            if (_selectedServices.contains(service)) {
                              _selectedServices.remove(service);
                            } else {
                              _selectedServices.add(service);
                            }
                          });
                        },
                      ),
                  ],
                ),
              const SizedBox(height: 16),

              // Phone Number input
              UiTextInput(
                label: 'Phone number',
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

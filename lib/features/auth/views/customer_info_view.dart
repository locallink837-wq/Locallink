import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/auth_repository.dart';
import '../state/auth_flow.dart';
import '../state/auth_validators.dart';
import '../widgets/auth_widgets.dart';
import 'location_permission_view.dart';

/// Customer info
/// Module 1 - Auth and onboarding  |  Owner: A
/// Last step of customer sign-up. Creates users/{uid} with role "customer".
class CustomerInfoView extends StatefulWidget {
  const CustomerInfoView({super.key});

  static const route = '/auth/customer-info';

  @override
  State<CustomerInfoView> createState() => _CustomerInfoViewState();
}

class _CustomerInfoViewState extends State<CustomerInfoView> {
  static const _repo = AuthRepository();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _area = TextEditingController();

  bool _phoneVerified = false; // came from phone OTP login
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = _repo.currentUser;
    if (user != null) {
      _name.text = user.displayName ?? '';
      final p = user.phoneNumber ?? '';
      if (p.isNotEmpty) {
        _phoneVerified = true;
        _phone.text = p;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = _repo.currentUser;
    if (user == null || user.isAnonymous) {
      setState(() => _error = 'Please sign in first.');
      return;
    }
    final name = _name.text.trim();
    final area = _area.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    if (!_phoneVerified && !AuthValidators.isIndianMobile(_phone.text)) {
      setState(() => _error = 'Enter a valid 10-digit mobile number.');
      return;
    }
    if (area.length < 2) {
      setState(() => _error = 'Please enter your home area.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final phone = _phoneVerified ? _phone.text.trim() : AuthValidators.toE164(_phone.text);
      final existing = await _repo.fetchProfile(user.uid);
      if (existing == null) {
        await _repo.createProfile(
          uid: user.uid,
          role: UserRole.customer,
          name: name,
          phone: phone,
          email: user.email ?? '',
          area: area,
          language: AuthFlow.language,
          photoUrl: user.photoURL ?? '',
        );
      } else {
        // Profile already exists (e.g. created earlier): update, never touch the role.
        await _repo.updateProfile(user.uid, {
          'name': name,
          'phone': phone,
          'area': area,
          'language': AuthFlow.language,
          'onboardingDone': true,
        });
      }
      await _repo.updateDisplayName(name);
      if (!mounted) return;
      Navigator.pushNamed(context, LocationPermissionView.route);
    } catch (e) {
      if (mounted) setState(() => _error = AuthRepository.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'About you',
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uiText(
                'Just three details and you are in.',
                size: 12.5,
                weight: FontWeight.w500,
                color: UiColors.muted,
              ),
              const SizedBox(height: 16),
              UiTextInput(label: 'Name', controller: _name, hintText: 'Your full name'),
              const SizedBox(height: 14),
              UiTextInput(
                label: _phoneVerified ? 'Phone (verified)' : 'Phone',
                controller: _phone,
                keyboardType: TextInputType.phone,
                enabled: !_phoneVerified,
                hintText: '10-digit mobile number',
                prefixIcon: _phoneVerified
                    ? const Icon(Icons.verified_rounded, color: UiColors.teal, size: 20)
                    : null,
              ),
              const SizedBox(height: 14),
              UiTextInput(
                label: 'Home area',
                controller: _area,
                hintText: 'e.g. Shivajinagar, Pune',
              ),
              AuthErrorBanner(_error),
            ],
          ),
        ),
        bottomButton: UiMainButton(
          label: 'Create account',
          isLoading: _busy,
          onPressed: _busy ? null : _submit,
        ),
      ),
    );
  }
}
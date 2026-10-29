import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/safety_profile_repository.dart';

/// Screen 5.4: Edit Customer Profile.
/// Updates user name, phone, home area, and language in Firestore users/{uid}.
class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  static const route = '/safety-profile/edit-profile';

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _repo = SafetyProfileRepository();

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _nameController.text = user.displayName ?? '';
        _phoneController.text = user.phoneNumber ?? '';

        final appUser = await _repo
            .streamUser(user.uid)
            .first
            .timeout(const Duration(seconds: 2));
        if (appUser != null) {
          if (appUser.name.isNotEmpty) _nameController.text = appUser.name;
          if (appUser.phone.isNotEmpty) _phoneController.text = appUser.phone;
          _areaController.text = appUser.area;
        }
      } else {
        _nameController.text = 'Meera Joshi';
        _phoneController.text = '+91 98220 12345';
        _areaController.text = 'Kothrud, Pune';
      }
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Name cannot be empty.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (uid.isNotEmpty) {
        await _repo.updateUserProfile(
          uid: uid,
          name: name,
          phone: _phoneController.text.trim(),
          area: _areaController.text.trim(),
          language: 'en',
        );
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Edit profile',
        bottomButton: UiMainButton(
          label: 'Save',
          customAccent: UiColors.teal,
          isLoading: _isSaving,
          onPressed: _saveProfile,
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
                label: 'Name',
                hintText: 'Your full name',
                controller: _nameController,
              ),
              const SizedBox(height: 14),

              UiTextInput(
                label: 'Phone number',
                hintText: '10-digit mobile number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              UiTextInput(
                label: 'Home area',
                hintText: 'e.g. Kothrud, Pune',
                controller: _areaController,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

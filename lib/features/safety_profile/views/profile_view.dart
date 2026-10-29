import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/app_user.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/safety_profile_repository.dart';
import 'edit_profile_view.dart';
import 'guest_requests_profile_view.dart';
import 'help_feedback_view.dart';
import 'settings_view.dart';

/// Screen 5.3: Customer Profile Hub.
/// Renders user info, photo avatar upload to Supabase, and navigation menu.
/// Redirects anonymous users to the Guest Profile screen.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  static const route = '/safety-profile/profile';

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _repo = SafetyProfileRepository();
  final _picker = ImagePicker();
  bool _isUploadingAvatar = false;
  String? _avatarUrl;

  Future<void> _pickAndUploadAvatar(String uid) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        imageQuality: 80,
      );

      if (picked != null) {
        setState(() => _isUploadingAvatar = true);
        final bytes = await picked.readAsBytes();
        final url = await _repo.uploadAvatar(uid: uid, bytes: bytes);

        if (!mounted) return;
        setState(() {
          _isUploadingAvatar = false;
          if (url != null) _avatarUrl = url;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      return const GuestRequestsProfileView();
    }

    final uid = user.uid;

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Profile',
        showBackButton: Navigator.canPop(context),
        body: StreamBuilder<AppUser?>(
          stream: _repo.streamUser(uid),
          builder: (context, snapshot) {
            final appUser = snapshot.data;
            final name = appUser?.name.isNotEmpty == true ? appUser!.name : (user.displayName ?? 'Customer');
            final phone = appUser?.phone.isNotEmpty == true ? appUser!.phone : (user.phoneNumber ?? '+91 98765 43210');
            final photo = _avatarUrl ?? (appUser?.photoUrl.isNotEmpty == true ? appUser!.photoUrl : null);

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Avatar with upload badge
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _pickAndUploadAvatar(uid),
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: UiColors.teal.withValues(alpha: 0.12),
                              border: Border.all(color: UiColors.line, width: 2),
                            ),
                            child: _isUploadingAvatar
                                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                                : photo != null
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: photo,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, url, error) => const Icon(
                                            Icons.person_rounded,
                                            size: 44,
                                            color: UiColors.teal,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.person_rounded, size: 44, color: UiColors.teal),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: UiColors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  uiText(name, size: 18, weight: FontWeight.w800),
                  const SizedBox(height: 2),
                  uiText(phone, size: 13, color: UiColors.muted),
                  const SizedBox(height: 24),

                  // Profile Menu items
                  UiListTile(
                    title: 'Edit profile',
                    subtitle: 'Name, phone, home area',
                    icon: Icons.person_outline_rounded,
                    customAccent: UiColors.teal,
                    onTap: () => Navigator.pushNamed(context, EditProfileView.route),
                  ),
                  UiListTile(
                    title: 'My requests',
                    subtitle: 'Track active and past service requests',
                    icon: Icons.assignment_outlined,
                    customAccent: UiColors.teal,
                    onTap: () => Navigator.pushNamed(context, '/requests/request-history'),
                  ),
                  UiListTile(
                    title: 'Settings',
                    subtitle: 'Language, notifications, appearance',
                    icon: Icons.settings_outlined,
                    customAccent: UiColors.teal,
                    onTap: () => Navigator.pushNamed(context, SettingsView.route),
                  ),
                  UiListTile(
                    title: 'Help and feedback',
                    subtitle: 'FAQs, contact support, send suggestions',
                    icon: Icons.help_outline_rounded,
                    customAccent: UiColors.teal,
                    onTap: () => Navigator.pushNamed(context, HelpFeedbackView.route),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

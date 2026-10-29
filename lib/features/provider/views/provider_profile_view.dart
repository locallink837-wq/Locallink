import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/listing.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';
import 'edit_services_view.dart';
import 'my_reviews_view.dart';
import 'service_area_view.dart';

/// Screen 6.13: Provider Profile.
/// Features avatar upload to avatars/{uid}/avatar.jpg, live listing rating,
/// navigation to all profile sub-screens, and secure logout.
class ProviderProfileView extends StatefulWidget {
  const ProviderProfileView({super.key});

  static const route = '/provider/provider-profile';

  @override
  State<ProviderProfileView> createState() => _ProviderProfileViewState();
}

class _ProviderProfileViewState extends State<ProviderProfileView> {
  final _repo = ProviderRepository();
  final _picker = ImagePicker();
  bool _isUploadingAvatar = false;
  String? _avatarUrl;

  Future<void> _pickAndUploadAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        imageQuality: 80,
      );

      if (picked != null) {
        setState(() => _isUploadingAvatar = true);
        final bytes = await picked.readAsBytes();
        final publicUrl = await _repo.uploadAvatar(uid: uid, bytes: bytes);

        if (!mounted) return;
        setState(() {
          _isUploadingAvatar = false;
          if (publicUrl != null) _avatarUrl = publicUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated successfully!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading avatar: $e')),
      );
    }
  }

  Future<void> _logOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: uiText('Log out', size: 18, weight: FontWeight.w800),
        content: uiText('Are you sure you want to log out of your provider account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: uiText('Cancel', color: UiColors.muted),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: UiColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/auth/splash', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Provider profile',
        showBackButton: Navigator.canPop(context),
        body: uid.isEmpty
            ? const Center(child: Text('Please log in'))
            : StreamBuilder<Map<String, dynamic>?>(
                stream: _repo.streamProvider(uid),
                builder: (context, provSnap) {
                  final provData = provSnap.data ?? {};
                  final displayName = provData['displayName']?.toString() ?? 'Provider';

                  return StreamBuilder<Listing?>(
                    stream: _repo.streamListing(uid),
                    builder: (context, listingSnap) {
                      final listing = listingSnap.data;
                      final rating = listing?.averageRating ?? 0.0;
                      final reviewCount = listing?.reviewCount ?? 0;
                      final photoUrl = _avatarUrl ?? (listing?.photoUrls.isNotEmpty == true ? listing!.photoUrls.first : null);

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            // Profile Avatar with tap to upload
                            Center(
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: UiColors.indigo.withValues(alpha: 0.12),
                                        border: Border.all(color: UiColors.line, width: 2),
                                      ),
                                      child: _isUploadingAvatar
                                          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                                          : photoUrl != null
                                              ? ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl: photoUrl,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) => const Icon(
                                                      Icons.person_rounded,
                                                      size: 48,
                                                      color: UiColors.indigo,
                                                    ),
                                                  ),
                                                )
                                              : const Icon(Icons.person_rounded, size: 48, color: UiColors.indigo),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: UiColors.indigo,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Name & Rating
                            uiText(displayName, size: 18, weight: FontWeight.w800),
                            const SizedBox(height: 4),
                            UiStarRating(
                              rating: rating > 0 ? rating : 5.0,
                              reviewCount: reviewCount,
                            ),
                            const SizedBox(height: 24),

                            // Sub-screens Navigation Menu
                            UiListTile(
                              title: 'Edit services',
                              subtitle: 'Categories, experience, 24x7 emergency',
                              icon: Icons.tune_rounded,
                              onTap: () => Navigator.pushNamed(context, EditServicesView.route),
                            ),
                            UiListTile(
                              title: 'Service area',
                              subtitle: 'Operating radius and center location',
                              icon: Icons.map_outlined,
                              onTap: () => Navigator.pushNamed(context, ServiceAreaView.route),
                            ),
                            UiListTile(
                              title: 'Reviews',
                              subtitle: 'Customer ratings and feedback history',
                              icon: Icons.star_border_rounded,
                              onTap: () => Navigator.pushNamed(context, MyReviewsView.route),
                            ),
                            const SizedBox(height: 12),

                            // Log out tile
                            UiListTile(
                              title: 'Log out',
                              subtitle: 'Sign out of your provider account',
                              icon: Icons.logout_rounded,
                              customAccent: UiColors.red,
                              onTap: _logOut,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

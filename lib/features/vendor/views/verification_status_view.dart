import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/listing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/vendor_repository.dart';
import 'register_shop_view.dart';
import 'vendor_dashboard_view.dart';

/// Screen 7.10: Vendor Verification Status.
/// Streams listing status (pending, active, blocked).
/// Renders approved badge, pending clock, or rejection reason with 'Fix and resubmit'.
class VerificationStatusView extends StatelessWidget {
  const VerificationStatusView({super.key});

  static const route = '/vendor/verification-status';

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final repo = VendorRepository();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final listingId = args['listingId'] as String?;

    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        body: SafeArea(
          child: StreamBuilder<Listing?>(
            stream: listingId != null
                ? repo.streamListingStatus(listingId).map((data) => data != null ? Listing.fromMap(listingId, data) : null)
                : (uid.isNotEmpty ? repo.streamOwnerListing(uid) : const Stream.empty()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }

              final listing = snapshot.data;
              if (listing == null) {
                return const EmptyState(
                  title: 'No listing found',
                  message: 'Please register your shop or place to check verification status.',
                );
              }

              final status = listing.status.toLowerCase();
              final isVerified = listing.verified || status == 'active';
              final isBlocked = status == 'blocked';

              if (isBlocked) {
                // Rejected / Blocked state
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: UiColors.red.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded, size: 40, color: UiColors.red),
                      ),
                      const SizedBox(height: 20),
                      uiText('Listing verification rejected', size: 22, weight: FontWeight.w800, align: TextAlign.center),
                      const SizedBox(height: 12),
                      const UiWarningBanner(
                        text: 'Reason: Business proof photo or address was invalid.',
                        icon: Icons.info_outline_rounded,
                      ),
                      const Spacer(),
                      UiMainButton(
                        label: 'Fix and resubmit',
                        customAccent: UiColors.amber,
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, RegisterShopView.route, (r) => false);
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                );
              }

              if (isVerified) {
                // Verified state
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, size: 44, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(height: 20),
                      uiText('Listing Verified', size: 24, weight: FontWeight.w800),
                      const SizedBox(height: 8),
                      uiText(
                        'Your business is active and visible to all customers across LocaLink.',
                        size: 13.5,
                        color: UiColors.muted,
                        align: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      UiListTile(
                        title: 'Documents approved',
                        subtitle: 'Proof of address and business verified',
                        icon: Icons.check_circle_outline_rounded,
                        trailing: const Icon(Icons.check, color: Color(0xFF2E7D32)),
                      ),
                      UiListTile(
                        title: 'Details checked',
                        subtitle: 'Operating hours and categories verified',
                        icon: Icons.check_circle_outline_rounded,
                        trailing: const Icon(Icons.check, color: Color(0xFF2E7D32)),
                      ),
                      const Spacer(),
                      UiMainButton(
                        label: 'Open vendor dashboard',
                        customAccent: UiColors.amber,
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, VendorDashboardView.route, (r) => false);
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                );
              }

              // Pending state
              return UiCoverScreen(
                icon: Icons.access_time_filled_rounded,
                customAccent: UiColors.amber,
                title: 'Listing verification in review',
                subtitle:
                    'Our moderation team is reviewing your storefront photos and details. Listings are typically verified within 2 to 4 hours.',
                primaryButtonText: 'Go to dashboard',
                onPrimaryPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, VendorDashboardView.route, (r) => false);
                },
                secondaryButtonText: 'Log out',
                onSecondaryPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: uiText('Log out', size: 18, weight: FontWeight.w800),
                      content: uiText('Are you sure you want to log out of your vendor account?'),
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
                  if (confirm == true) {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/auth/splash', (r) => false);
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

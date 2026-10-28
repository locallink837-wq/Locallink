import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';
import 'provider_dashboard_view.dart';
import 'register_core_view.dart';
import 'verification_rejected_view.dart';

/// Screen 6.5: Pending Verification Cover Screen.
/// Streams providers/{uid} live and automatically switches when approved or rejected.
class PendingView extends StatefulWidget {
  const PendingView({super.key});

  static const route = '/provider/pending';

  @override
  State<PendingView> createState() => _PendingViewState();
}

class _PendingViewState extends State<PendingView> {
  final _repo = ProviderRepository();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: StreamBuilder<Map<String, dynamic>?>(
        stream: uid.isNotEmpty ? _repo.streamProvider(uid) : const Stream.empty(),
        builder: (context, snapshot) {
          // Check verification status from live stream
          final data = snapshot.data;
          final status = data?['verificationStatus']?.toString().toLowerCase();

          // Auto-route on status changes
          if (status == 'approved') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(context, ProviderDashboardView.route, (r) => false);
            });
          } else if (status == 'rejected') {
            final reason = data?['rejectionReason']?.toString() ?? 'Documents could not be verified.';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                VerificationRejectedView.route,
                (r) => false,
                arguments: {'rejectionReason': reason},
              );
            });
          }

          return UiCoverScreen(
            icon: Icons.access_time_filled_rounded,
            title: 'We are verifying your details',
            subtitle:
                'Our team is reviewing your profile and identity proofs. This usually takes under 2 hours. You can update your profile while you wait.',
            primaryButtonText: 'Log out',
            onPrimaryPressed: () async {
              final confirm = await showDialog<bool>(
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
              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/auth/splash', (r) => false);
                }
              }
            },
            secondaryButtonText: 'Edit profile',
            onSecondaryPressed: () {
              Navigator.pushNamed(context, RegisterCoreView.route);
            },
          );
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/listing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/vendor_repository.dart';
import 'edit_listing_view.dart';
import 'verification_status_view.dart';

/// Screen 7.8: Vendor Dashboard.
/// Streams listing_stats/{listingId} (views, calls, directions) and owner's listing.
/// Button "Confirm info is correct" updates only lastConfirmedAt in Firestore.
class VendorDashboardView extends StatefulWidget {
  const VendorDashboardView({super.key});

  static const route = '/vendor/vendor-dashboard';

  @override
  State<VendorDashboardView> createState() => _VendorDashboardViewState();
}

class _VendorDashboardViewState extends State<VendorDashboardView> {
  final _repo = VendorRepository();
  bool _isConfirming = false;
  String? _statusMessage;

  Future<void> _handleConfirmInfo(String listingId) async {
    setState(() => _isConfirming = true);
    try {
      await _repo.confirmListingInfo(listingId);
      if (!mounted) return;
      setState(() {
        _isConfirming = false;
        _statusMessage = 'Thank you! Your listing info has been verified as up to date.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (uid.isEmpty) {
      return const Scaffold(
        body: EmptyState(
          title: 'Not signed in',
          message: 'Please sign in to view your vendor dashboard.',
        ),
      );
    }

    return Theme(
      data: uiFeatureTheme(context, UiColors.amber),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (idx) {
            if (idx == 1) {
              Navigator.pushNamed(context, EditListingView.route);
            } else if (idx == 2) {
              Navigator.pushNamed(context, VerificationStatusView.route);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded, color: UiColors.amber),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_note_rounded),
              selectedIcon: Icon(Icons.edit_note_rounded, color: UiColors.amber),
              label: 'Edit Info',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield_rounded, color: UiColors.amber),
              label: 'Status',
            ),
          ],
        ),
        body: SafeArea(
          child: StreamBuilder<Listing?>(
            stream: _repo.streamOwnerListing(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }

              final listing = snapshot.data;
              if (listing == null) {
                return const EmptyState(
                  title: 'No business listing found',
                  message: 'You have not registered or claimed a shop or place yet.',
                  icon: Icons.storefront_rounded,
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              uiText('Your Business', size: 12, color: UiColors.muted),
                              uiText(listing.name, size: 20, weight: FontWeight.w800),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: listing.verified
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            listing.verified ? 'Verified' : 'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: listing.verified
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_statusMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: uiText(_statusMessage!, size: 12.5, color: const Color(0xFF1B5E20)),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // 4-box stats grid: Views, Calls, Directions, Reviews
                    StreamBuilder<Map<String, dynamic>?>(
                      stream: _repo.streamListingStats(listing.id),
                      builder: (context, statsSnap) {
                        final stats = statsSnap.data ?? {};
                        final views = stats['views'] ?? 0;
                        final calls = stats['calls'] ?? 0;
                        final directions = stats['directions'] ?? 0;
                        final rating = listing.averageRating;

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.45,
                          children: [
                            _VendorStatCard(
                              icon: Icons.visibility_outlined,
                              title: 'Views',
                              value: '$views',
                            ),
                            _VendorStatCard(
                              icon: Icons.phone_in_talk_outlined,
                              title: 'Calls',
                              value: '$calls',
                            ),
                            _VendorStatCard(
                              icon: Icons.directions_outlined,
                              title: 'Directions',
                              value: '$directions',
                            ),
                            _VendorStatCard(
                              icon: Icons.star_rounded,
                              title: 'Reviews',
                              value: rating > 0 ? rating.toStringAsFixed(1) : '5.0',
                              subtitle: '${listing.reviewCount} total',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Freshness confirmation banner & button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: UiColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          uiText('Keep listing fresh', size: 14, weight: FontWeight.w800),
                          const SizedBox(height: 4),
                          uiText(
                            'Verified shops get ranked first in local search results.',
                            size: 12,
                            color: UiColors.muted,
                          ),
                          const SizedBox(height: 14),
                          UiMainButton(
                            label: 'Confirm info is correct',
                            customAccent: UiColors.amber,
                            isLoading: _isConfirming,
                            onPressed: () => _handleConfirmInfo(listing.id),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Edit info quick link
                    UiListTile(
                      title: 'Edit hours and inventory',
                      subtitle: 'Update timings, contact number, or items',
                      icon: Icons.edit_note_rounded,
                      customAccent: UiColors.amber,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          EditListingView.route,
                          arguments: {'listing': listing},
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VendorStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const _VendorStatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: UiColors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: UiColors.amber),
              ),
              const SizedBox(width: 8),
              uiText(title, size: 11, color: UiColors.muted),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: UiColors.ink,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                uiText(subtitle!, size: 10, color: UiColors.muted),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

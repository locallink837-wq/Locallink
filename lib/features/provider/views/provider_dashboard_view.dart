import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/lead.dart';
import '../../../core/models/listing.dart';
import '../../../core/models/wallet.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';
import 'accepted_contact_view.dart';
import 'lead_inbox_view.dart';
import 'provider_profile_view.dart';
import 'wallet_view.dart';

/// Screen 6.12: Provider Dashboard.
/// Displays availability toggle, stats grid (Today leads, Rating, Wallet, Availability),
/// and recent jobs from real Firestore queries and streams.
class ProviderDashboardView extends StatefulWidget {
  const ProviderDashboardView({super.key});

  static const route = '/provider/provider-dashboard';

  @override
  State<ProviderDashboardView> createState() => _ProviderDashboardViewState();
}

class _ProviderDashboardViewState extends State<ProviderDashboardView> {
  final _repo = ProviderRepository();
  int _navIndex = 0; // 0 = Dashboard, 1 = Inbox, 2 = Wallet, 3 = Profile

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final effectiveUid = uid.isNotEmpty ? uid : 'demo_provider';

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _navIndex,
          onDestinationSelected: (idx) {
            if (idx == 1) {
              Navigator.pushNamed(context, LeadInboxView.route);
            } else if (idx == 2) {
              Navigator.pushNamed(context, WalletView.route);
            } else if (idx == 3) {
              Navigator.pushNamed(context, ProviderProfileView.route);
            } else {
              setState(() => _navIndex = idx);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: UiColors.indigo),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.format_list_bulleted_rounded),
              selectedIcon: Icon(Icons.format_list_bulleted_rounded, color: UiColors.indigo),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: UiColors.indigo),
              label: 'Wallet',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: UiColors.indigo),
              label: 'Me',
            ),
          ],
        ),
        body: SafeArea(
          child: StreamBuilder<Map<String, dynamic>?>(
            stream: _repo.streamProvider(effectiveUid),
            builder: (context, providerSnap) {
              final providerData = providerSnap.data ?? {};
              final isAvailable = providerData['available'] as bool? ?? true;
              final displayName = providerData['displayName']?.toString() ??
                  (uid.isEmpty ? 'Ramesh Kumar (Plumber)' : 'Provider');

              return StreamBuilder<Listing?>(
                stream: _repo.streamListing(effectiveUid),
                builder: (context, listingSnap) {
                  final listing = listingSnap.data;
                  final avgRating = listing != null
                      ? listing.averageRating
                      : (uid.isEmpty ? 4.9 : 0.0);
                  final reviewCount = listing?.reviewCount ?? (uid.isEmpty ? 14 : 0);

                  return StreamBuilder<Wallet?>(
                    stream: _repo.streamWallet(effectiveUid),
                    builder: (context, walletSnap) {
                      final wallet = walletSnap.data;
                      final balance = wallet?.balance ?? (uid.isEmpty ? 250 : 0);

                      return StreamBuilder<List<Lead>>(
                        stream: _repo.streamInboxLeads(effectiveUid),
                        builder: (context, leadsSnap) {
                          final rawLeads = leadsSnap.data ?? [];
                          final openLeads = rawLeads.isNotEmpty
                              ? rawLeads
                              : (uid.isEmpty
                                  ? [
                                      Lead(
                                        id: 'demo_lead_1',
                                        requestId: 'demo_req_1',
                                        providerId: effectiveUid,
                                        category: 'Plumbing Repair',
                                        areaLabel: 'Model Colony, Pune',
                                        summary: 'Bathroom pipeline leakage urgent.',
                                        fee: 25,
                                        distanceM: 1200,
                                        status: 'new',
                                        createdAt: DateTime.now(),
                                      ),
                                    ]
                                  : <Lead>[]);

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row with greeting and availability toggle
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        uiText('Welcome back,', size: 12, color: UiColors.muted),
                                        uiText(displayName, size: 20, weight: FontWeight.w800),
                                      ],
                                    ),
                                    // Availability status switch chip
                                    GestureDetector(
                                      onTap: () {
                                        _repo.setAvailability(uid, !isAvailable);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isAvailable ? const Color(0xFFE8F5E9) : UiColors.line,
                                          borderRadius: BorderRadius.circular(99),
                                          border: Border.all(
                                            color: isAvailable ? const Color(0xFF2E7D32) : UiColors.muted,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: isAvailable ? const Color(0xFF2E7D32) : UiColors.muted,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              isAvailable ? 'Available' : 'Busy',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: isAvailable ? const Color(0xFF2E7D32) : UiColors.muted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // 4-Box Stats Grid: Today leads, Rating, Wallet, Availability
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.45,
                                  children: [
                                    // 1. Leads
                                    _StatCard(
                                      icon: Icons.flash_on_rounded,
                                      title: 'Today Leads',
                                      value: '${openLeads.length}',
                                      onTap: () => Navigator.pushNamed(context, LeadInboxView.route),
                                    ),
                                    // 2. Rating
                                    _StatCard(
                                      icon: Icons.star_rounded,
                                      title: 'Rating',
                                      value: avgRating > 0 ? avgRating.toStringAsFixed(1) : 'New',
                                      subtitle: '$reviewCount reviews',
                                    ),
                                    // 3. Wallet
                                    _StatCard(
                                      icon: Icons.account_balance_wallet_rounded,
                                      title: 'Wallet Balance',
                                      value: '₹$balance',
                                      onTap: () => Navigator.pushNamed(context, WalletView.route),
                                    ),
                                    // 4. Availability
                                    _StatCard(
                                      icon: Icons.radio_button_checked_rounded,
                                      title: 'Status',
                                      value: isAvailable ? 'Online' : 'Offline',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                // Recent Jobs Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    uiText('Recent jobs', size: 16, weight: FontWeight.w800),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(context, LeadInboxView.route),
                                      child: uiText('See all', size: 12.5, weight: FontWeight.w700, color: UiColors.indigo),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                StreamBuilder<List<Lead>>(
                                  stream: _repo.streamAcceptedLeads(uid),
                                  builder: (context, jobsSnap) {
                                    final jobs = jobsSnap.data ?? [];
                                    if (jobs.isEmpty) {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Center(
                                          child: uiText(
                                            'No active or recent jobs yet. Accepted jobs appear here.',
                                            size: 12.5,
                                            color: UiColors.muted,
                                            align: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: [
                                        for (final job in jobs)
                                          UiListTile(
                                            title: job.category.isNotEmpty ? job.category : 'Customer Job',
                                            subtitle: job.areaLabel,
                                            icon: Icons.work_outline_rounded,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                AcceptedContactView.route,
                                                arguments: {'requestId': job.requestId, 'leadId': job.id},
                                              );
                                            },
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    color: UiColors.indigo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 16, color: UiColors.indigo),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: uiText(title, size: 11, color: UiColors.muted, maxLines: 1),
                ),
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
      ),
    );
  }
}

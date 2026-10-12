import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/lead.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/provider_repository.dart';
import 'accepted_contact_view.dart';
import 'lead_detail_view.dart';

/// Screen 6.6: Provider Lead Inbox.
/// Streams open leads and accepted jobs with tabs, distance, fee, and summary.
/// Strictly hides customer phone number until accepted.
class LeadInboxView extends StatefulWidget {
  const LeadInboxView({super.key});

  static const route = '/provider/lead-inbox';

  @override
  State<LeadInboxView> createState() => _LeadInboxViewState();
}

class _LeadInboxViewState extends State<LeadInboxView> {
  final _repo = ProviderRepository();
  int _selectedTab = 0; // 0 = Open leads, 1 = Accepted jobs

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Lead inbox',
        showBackButton: Navigator.canPop(context),
        body: Column(
          children: [
            // Tabs: Open, Accepted
            Row(
              children: [
                Expanded(
                  child: UiChip(
                    label: 'Open leads',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: UiChip(
                    label: 'Accepted jobs',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Notice note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: UiColors.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined, size: 16, color: UiColors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: uiText(
                      'Customer phone number is hidden until you accept the lead.',
                      size: 11,
                      color: UiColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Leads stream
            Expanded(
              child: uid.isEmpty
                  ? const EmptyState(
                      title: 'Not logged in',
                      message: 'Please log in to see incoming job requests.',
                    )
                  : StreamBuilder<List<Lead>>(
                      stream: _selectedTab == 0 ? _repo.streamInboxLeads(uid) : _repo.streamAcceptedLeads(uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return ErrorView(
                            message: 'Could not load leads: ${snapshot.error}',
                            onRetry: () => setState(() {}),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }

                        final leads = snapshot.data ?? [];
                        if (leads.isEmpty) {
                          return EmptyState(
                            title: _selectedTab == 0 ? 'No new leads' : 'No accepted jobs',
                            message: _selectedTab == 0
                                ? 'New customer requests in your area will appear here automatically.'
                                : 'Jobs you accept will appear here.',
                            icon: Icons.inbox_rounded,
                          );
                        }

                        return ListView.builder(
                          itemCount: leads.length,
                          itemBuilder: (context, index) {
                            final lead = leads[index];
                            final distanceText = lead.formattedDistance;

                            return UiListTile(
                              title: '${lead.category.isNotEmpty ? lead.category : "Request"} • $distanceText',
                              subtitle: lead.summary.isNotEmpty ? lead.summary : lead.areaLabel,
                              icon: Icons.build_circle_outlined,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: UiColors.indigo.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '₹${lead.fee}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: UiColors.indigo,
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (_selectedTab == 0) {
                                  // Mark as viewed
                                  _repo.markLeadViewed(lead.id);
                                  Navigator.pushNamed(
                                    context,
                                    LeadDetailView.route,
                                    arguments: {'lead': lead},
                                  );
                                } else {
                                  Navigator.pushNamed(
                                    context,
                                    AcceptedContactView.route,
                                    arguments: {'requestId': lead.requestId, 'leadId': lead.id},
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

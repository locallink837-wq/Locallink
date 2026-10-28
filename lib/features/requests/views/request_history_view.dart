import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../app/shells/customer_shell.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/models/service_request.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/requests_repository.dart';
import 'finding_providers_view.dart';
import 'job_done_review_view.dart';
import 'request_accepted_view.dart';

/// Screen 3.8: Customer Request History.
/// Displays tabs for Active, Done, and Cancelled requests.
class RequestHistoryView extends StatefulWidget {
  const RequestHistoryView({super.key});

  static const route = '/requests/request-history';

  @override
  State<RequestHistoryView> createState() => _RequestHistoryViewState();
}

class _RequestHistoryViewState extends State<RequestHistoryView> {
  final _repo = RequestsRepository();
  int _selectedTab = 0; // 0 = Active, 1 = Done, 2 = Cancelled

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: AppLanguage.t('my_requests', defaultText: 'My requests'),
        onBack: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            CustomerShell.of(context)?.setTab(0);
          }
        },
        body: Column(
          children: [
            // Tabs: Active, Done, Cancelled
            Row(
              children: [
                Expanded(
                  child: UiChip(
                    label: 'Active',
                    customAccent: UiColors.teal,
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: UiChip(
                    label: 'Done',
                    customAccent: UiColors.teal,
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: UiChip(
                    label: 'Cancelled',
                    customAccent: UiColors.teal,
                    isSelected: _selectedTab == 2,
                    onTap: () => setState(() => _selectedTab = 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Requests Stream
            Expanded(
              child: uid.isEmpty
                  ? const EmptyState(
                      title: 'Please sign in',
                      message: 'Sign in to view your past and active service requests.',
                    )
                  : StreamBuilder<List<ServiceRequest>>(
                      stream: _repo.streamCustomerRequests(uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        }

                        final all = snapshot.data ?? [];
                        final filtered = all.where((r) {
                          final s = r.status.toLowerCase();
                          if (_selectedTab == 0) {
                            return s == 'searching' || s == 'accepted' || s == 'on_the_way' || s == 'in_progress';
                          } else if (_selectedTab == 1) {
                            return s == 'done';
                          } else {
                            return s == 'cancelled' || s == 'no_provider';
                          }
                        }).toList();

                        if (filtered.isEmpty) {
                          return EmptyState(
                            title: _selectedTab == 0
                                ? 'No active requests'
                                : (_selectedTab == 1 ? 'No completed jobs' : 'No cancelled requests'),
                            message: 'Your service request history will appear here.',
                            icon: Icons.assignment_outlined,
                          );
                        }

                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final req = filtered[index];
                            final statusLabel = req.parsedStatus.label;

                            return UiListTile(
                              title: req.category.isNotEmpty ? req.category : 'Service Request',
                              subtitle: req.description.isNotEmpty ? req.description : req.address,
                              icon: Icons.home_repair_service_outlined,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: UiColors.teal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: UiColors.teal,
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (req.status == 'searching') {
                                  Navigator.pushNamed(
                                    context,
                                    FindingProvidersView.route,
                                    arguments: {'requestId': req.id},
                                  );
                                } else if (req.isAccepted || req.status == 'on_the_way' || req.status == 'in_progress') {
                                  Navigator.pushNamed(
                                    context,
                                    RequestAcceptedView.route,
                                    arguments: {'request': req, 'requestId': req.id},
                                  );
                                } else if (req.status == 'done') {
                                  Navigator.pushNamed(
                                    context,
                                    JobDoneReviewView.route,
                                    arguments: {'request': req, 'requestId': req.id},
                                  );
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => Theme(
                                      data: uiFeatureTheme(context, UiColors.teal),
                                      child: UiBottomSheetFrame(
                                        title: req.category.isNotEmpty ? req.category : 'Request details',
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            uiText('Status: ${req.parsedStatus.label}', weight: FontWeight.w700),
                                            const SizedBox(height: 8),
                                            uiText('Problem: ${req.description.isNotEmpty ? req.description : 'No description'}', color: UiColors.muted),
                                            const SizedBox(height: 8),
                                            uiText('Address: ${req.address}', color: UiColors.muted),
                                            const SizedBox(height: 18),
                                            UiMainButton(
                                              label: 'Close',
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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

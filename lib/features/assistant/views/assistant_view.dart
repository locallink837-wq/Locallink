import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/models/ai_session.dart';
import '../../../core/models/relocation_plan.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/assistant_repository.dart';
import 'ai_result_view.dart';
import 'checklist_view.dart';
import 'new_to_city_form_view.dart';
import 'photo_consent_view.dart';

/// Screen 4.1: AI Assistant Hub.
/// Primary entry point for Module 4 (Tab 3 in CustomerShell).
/// Features Visual Problem Diagnosis and New to City Relocation Checklist.
class AssistantView extends StatefulWidget {
  const AssistantView({super.key});

  static const route = '/assistant/assistant';

  @override
  State<AssistantView> createState() => _AssistantViewState();
}

class _AssistantViewState extends State<AssistantView> {
  final _repo = AssistantRepository();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: UiColors.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: UiColors.teal, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          uiText('LocaLink AI Assistant', size: 20, weight: FontWeight.w800),
                          const SizedBox(height: 2),
                          uiText(
                            'Smart repair diagnoses & neighborhood guides',
                            size: 13,
                            color: UiColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Active Relocation Plan Banner (if present)
                StreamBuilder<RelocationPlan?>(
                  stream: _repo.streamActivePlan(uid),
                  builder: (context, planSnap) {
                    final plan = planSnap.data ?? _repo.cachedPlan;
                    if (plan == null) return const SizedBox.shrink();

                    return Column(
                      children: [
                        _buildActivePlanBanner(context, plan),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),

                // Action Card 1: Visual Home Repair Diagnosis
                _buildActionCard(
                  context: context,
                  title: 'Snap & Diagnose Home Issue',
                  subtitle:
                      'Take a photo of a leak, short circuit, or broken fixture. AI identifies the issue, suggests safety tips, and estimates fair repair costs.',
                  badge: 'Instant AI',
                  badgeColor: UiColors.teal,
                  icon: Icons.camera_alt_rounded,
                  iconColor: UiColors.teal,
                  buttonText: 'Take or Upload Photo',
                  onTap: () {
                    Navigator.pushNamed(context, PhotoConsentView.route);
                  },
                ),
                const SizedBox(height: 16),

                // Action Card 2: New to City Relocation Checklist
                _buildActionCard(
                  context: context,
                  title: 'New to the City? Move-in Guide',
                  subtitle:
                      'Moving to a new area? Get a step-by-step checklist for RO water, WiFi, door locks, and vetted local vendors.',
                  badge: 'Checklist',
                  badgeColor: UiColors.indigo,
                  icon: Icons.location_city_rounded,
                  iconColor: UiColors.indigo,
                  buttonText: 'Create / View Guide',
                  onTap: () {
                    if (_repo.cachedPlan != null) {
                      Navigator.pushNamed(
                        context,
                        ChecklistView.route,
                        arguments: {'plan': _repo.cachedPlan},
                      );
                    } else {
                      Navigator.pushNamed(context, NewToCityFormView.route);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Recent AI Diagnoses Section
                uiText('Recent Diagnoses', size: 16, weight: FontWeight.w700),
                const SizedBox(height: 10),

                StreamBuilder<List<AiSession>>(
                  stream: _repo.streamRecentSessions(uid),
                  builder: (context, snapshot) {
                    final sessions = snapshot.data ?? _repo.cachedSessions;

                    if (sessions.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: UiColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: UiColors.line),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.image_search_rounded, size: 38, color: UiColors.muted.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            uiText('No recent diagnoses yet', size: 14, weight: FontWeight.w600, color: UiColors.muted),
                            const SizedBox(height: 4),
                            uiText(
                              'Snap a photo of any broken household item to get your first repair diagnosis.',
                              size: 12.5,
                              color: UiColors.muted,
                              align: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sessions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final s = sessions[index];
                        return _buildSessionTile(context, s);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivePlanBanner(BuildContext context, RelocationPlan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UiColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UiColors.indigo.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: UiColors.indigo.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: UiColors.indigo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: uiText('ACTIVE MOVE-IN PLAN', size: 11, weight: FontWeight.w700, color: UiColors.indigo),
              ),
              const Spacer(),
              uiText(
                '${plan.completedTasks}/${plan.totalTasks} Done',
                size: 12.5,
                weight: FontWeight.w700,
                color: UiColors.indigo,
              ),
            ],
          ),
          const SizedBox(height: 8),
          uiText('${plan.destinationArea} Relocation Guide', size: 15, weight: FontWeight.w700),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: plan.progress,
              backgroundColor: UiColors.line,
              valueColor: const AlwaysStoppedAnimation<Color>(UiColors.indigo),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, ChecklistView.route, arguments: {'plan': plan});
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  uiText('Open Checklist', size: 13, weight: FontWeight.w700, color: UiColors.indigo),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: UiColors.indigo),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color iconColor,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: UiColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UiColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: uiText(badge.toUpperCase(), size: 10.5, weight: FontWeight.w800, color: badgeColor),
                    ),
                    const SizedBox(height: 4),
                    uiText(title, size: 16, weight: FontWeight.w800),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          uiText(subtitle, size: 13, color: UiColors.muted, height: 1.4),
          const SizedBox(height: 16),
          UiMainButton(
            label: buttonText,
            customAccent: iconColor,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, AiSession session) {
    return Container(
      decoration: BoxDecoration(
        color: UiColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UiColors.line),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: UiColors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.build_circle_outlined, color: UiColors.teal),
        ),
        title: uiText(session.problemTitle, size: 14.5, weight: FontWeight.w700),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: UiColors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: uiText(session.category, size: 11, weight: FontWeight.w700, color: UiColors.teal),
                ),
                const SizedBox(width: 8),
                uiText(session.priceRangeDisplay, size: 12, weight: FontWeight.w600, color: UiColors.muted),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: UiColors.muted),
        onTap: () {
          Navigator.pushNamed(
            context,
            AiResultView.route,
            arguments: {'session': session},
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/models/ai_session.dart';
import '../../../core/widgets/ui_kit.dart';
import 'follow_up_question_view.dart';

/// Screen 4.3: AI Diagnostic Result.
/// Displays structured Gemini diagnosis: root cause, safety tips, estimated cost, and direct booking CTA.
class AiResultView extends StatelessWidget {
  const AiResultView({super.key});

  static const route = '/assistant/ai-result';

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final session = args['session'] as AiSession? ??
        AiSession(
          id: 'demo',
          userId: 'guest',
          problemTitle: 'Leaking Sink Angle Valve',
          category: 'Plumber',
          diagnosis:
              'Compression joint failure or degraded PTFE thread tape causing persistent water leakage around the spindle assembly.',
          safetyTips: 'Turn off the main stopcock or isolation valve under the basin immediately to avoid cabinet wood swelling.',
          estimatedCostMin: 250,
          estimatedCostMax: 450,
          urgency: 'today',
          confidence: 0.94,
          createdAt: DateTime.now(),
        );

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Diagnostic Result',
        bottomButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiMainButton(
              label: 'Book Verified ${session.category}',
              customAccent: UiColors.teal,
              onPressed: () {
                // Deep link into Module 3 Service Request Form with pre-filled category
                Navigator.pushNamed(
                  context,
                  '/requests/request-form',
                  arguments: {
                    'category': session.category,
                    'description': '${session.problemTitle} — ${session.diagnosis}',
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: uiText('Done & Back to Hub', size: 13, weight: FontWeight.w700, color: UiColors.muted),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: UiColors.card,
                  borderRadius: BorderRadius.circular(18),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: UiColors.teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_outlined, size: 15, color: UiColors.teal),
                              const SizedBox(width: 5),
                              uiText(
                                '${(session.confidence * 100).toInt()}% Match',
                                size: 11.5,
                                weight: FontWeight.w800,
                                color: UiColors.teal,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: session.urgency == 'now'
                                ? UiColors.red.withValues(alpha: 0.12)
                                : UiColors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: uiText(
                            session.urgency == 'now' ? 'URGENT' : 'ACTION RECOMMENDED',
                            size: 11,
                            weight: FontWeight.w800,
                            color: session.urgency == 'now' ? UiColors.red : UiColors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    uiText(session.problemTitle, size: 20, weight: FontWeight.w800),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        uiText('Recommended Trade: ', size: 13, color: UiColors.muted),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: UiColors.teal,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: uiText(session.category, size: 12, weight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Safety Tip Card
              if (session.safetyTips.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: UiColors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: UiColors.amber, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            uiText('Safety Precaution', size: 13.5, weight: FontWeight.w800, color: UiColors.amber),
                            const SizedBox(height: 4),
                            uiText(
                              session.safetyTips,
                              size: 12.5,
                              color: UiColors.ink,
                              height: 1.4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Detailed Diagnosis Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: UiColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: UiColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    uiText('Gemini Technical Analysis', size: 14.5, weight: FontWeight.w800),
                    const SizedBox(height: 8),
                    uiText(
                      session.diagnosis,
                      size: 13.5,
                      color: UiColors.ink,
                      height: 1.5,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Fair Cost Estimate Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: UiColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: UiColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.currency_rupee, color: UiColors.teal, size: 20),
                        const SizedBox(width: 6),
                        uiText('Fair Labor Cost Estimate', size: 14.5, weight: FontWeight.w800),
                      ],
                    ),
                    const SizedBox(height: 10),
                    uiText(
                      session.priceRangeDisplay,
                      size: 26,
                      weight: FontWeight.w900,
                      color: UiColors.teal,
                    ),
                    const SizedBox(height: 4),
                    uiText(
                      'Standard local benchmark for visit & basic labor in your city. Replacement spare parts are billed separately upon inspection.',
                      size: 12,
                      color: UiColors.muted,
                      height: 1.35,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Clarifying question link
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      FollowUpQuestionView.route,
                      arguments: {'session': session},
                    );
                  },
                  icon: const Icon(Icons.help_outline_rounded, size: 16, color: UiColors.teal),
                  label: uiText('Not sure? Answer 2 quick questions', size: 12.5, weight: FontWeight.w700, color: UiColors.teal),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

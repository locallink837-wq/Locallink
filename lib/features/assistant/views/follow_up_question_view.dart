import 'package:flutter/material.dart';

import '../../../core/models/ai_session.dart';
import '../../../core/widgets/ui_kit.dart';
import 'ai_result_view.dart';

/// Screen 4.4: AI Follow-Up Clarifying Questions.
/// Clarifies ambiguous symptoms with quick interactive selector chips.
class FollowUpQuestionView extends StatefulWidget {
  const FollowUpQuestionView({super.key});

  static const route = '/assistant/follow-up-question';

  @override
  State<FollowUpQuestionView> createState() => _FollowUpQuestionViewState();
}

class _FollowUpQuestionViewState extends State<FollowUpQuestionView> {
  String _selectedTiming = 'Just started today';
  String _selectedSymptom = 'Continuous leakage / noise';
  bool _isUpdating = false;

  final _timingOptions = [
    'Just started today',
    'Started a few days ago',
    'Recurring issue for weeks',
  ];

  final _symptomOptions = [
    'Continuous leakage / noise',
    'Only occurs when turned on',
    'Burning smell or warm surface',
    'Completely non-functional',
  ];

  void _onConfirm(AiSession session) {
    setState(() => _isUpdating = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isUpdating = false);

      final updated = session.copyWith(
        confidence: 0.98,
        safetyTips: _selectedSymptom.contains('Burning')
            ? 'Electrical hazard detected! Switch off the main MCB immediately.'
            : session.safetyTips,
      );

      Navigator.pushReplacementNamed(
        context,
        AiResultView.route,
        arguments: {'session': updated},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final session = args['session'] as AiSession? ??
        AiSession(
          id: 'demo',
          userId: 'guest',
          problemTitle: 'Household Repair',
          category: 'Plumber',
          diagnosis: 'General diagnostic assessment',
          createdAt: DateTime.now(),
        );

    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Refine Diagnosis',
        bottomButton: UiMainButton(
          label: _isUpdating ? 'Refining...' : 'Update Diagnosis',
          isLoading: _isUpdating,
          customAccent: UiColors.teal,
          onPressed: () => _onConfirm(session),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              uiText('Answer 2 Quick Questions', size: 18, weight: FontWeight.w800),
              const SizedBox(height: 6),
              uiText(
                'Help Gemini AI pinpoint the exact problem and estimate repair labor accurately.',
                size: 13.5,
                color: UiColors.muted,
                height: 1.4,
              ),
              const SizedBox(height: 24),

              // Question 1: Timing
              uiText('1. When did this issue start occurring?', size: 14.5, weight: FontWeight.w700),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final opt in _timingOptions)
                    UiChip(
                      label: opt,
                      isSelected: _selectedTiming == opt,
                      customAccent: UiColors.teal,
                      onTap: () => setState(() => _selectedTiming = opt),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Question 2: Symptoms
              uiText('2. Any additional symptoms observed?', size: 14.5, weight: FontWeight.w700),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sym in _symptomOptions)
                    UiChip(
                      label: sym,
                      isSelected: _selectedSymptom == sym,
                      customAccent: UiColors.teal,
                      onTap: () => setState(() => _selectedSymptom = sym),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

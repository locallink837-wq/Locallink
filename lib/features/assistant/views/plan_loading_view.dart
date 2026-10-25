import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/assistant_repository.dart';
import 'checklist_view.dart';

/// Screen 4.7: Plan Generation Loading Screen.
/// Displays animated progress with rotating relocation insights while Gemini AI compiles the move-in plan.
class PlanLoadingView extends StatefulWidget {
  const PlanLoadingView({super.key});

  static const route = '/assistant/plan-loading';

  @override
  State<PlanLoadingView> createState() => _PlanLoadingViewState();
}

class _PlanLoadingViewState extends State<PlanLoadingView> {
  final _repo = AssistantRepository();
  int _tipIndex = 0;
  Timer? _tipTimer;

  final _tips = [
    'Curating Day 1 water and lock essentials...',
    'Mapping trusted electrical and broadband technicians...',
    'Identifying nearby 24x7 pharmacies and medical clinics...',
    'Finalizing your personalized move-in checklist...',
  ];

  @override
  void initState() {
    super.initState();
    _startTipRotation();
    _generatePlan();
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  void _startTipRotation() {
    _tipTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    });
  }

  Future<void> _generatePlan() async {
    // Small delay so user sees smooth animated transition
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final area = (args['destinationArea'] ?? 'Pune').toString();
    final household = (args['householdType'] ?? 'Family').toString();
    final needs = (args['immediateNeeds'] as List<dynamic>?)?.map((e) => e.toString()).toList();

    try {
      final plan = await _repo.generateRelocationPlan(
        destinationArea: area,
        householdType: household,
        immediateNeeds: needs,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        ChecklistView.route,
        arguments: {'plan': plan},
      );
    } catch (_) {
      if (!mounted) return;
      // Fallback: get cached plan or build default
      final fallbackPlan = _repo.cachedPlan;
      if (fallbackPlan != null) {
        Navigator.pushReplacementNamed(
          context,
          ChecklistView.route,
          arguments: {'plan': fallbackPlan},
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: Scaffold(
        backgroundColor: UiColors.bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: UiColors.indigo.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(UiColors.indigo),
                  ),
                ),
                const SizedBox(height: 28),
                uiText('Generating Your Move-In Guide', size: 19, weight: FontWeight.w800, align: TextAlign.center),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_tipIndex),
                    child: uiText(
                      _tips[_tipIndex],
                      size: 13.5,
                      color: UiColors.muted,
                      align: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/models/relocation_plan.dart';
import '../../../core/widgets/ui_kit.dart';

/// Screen 4.9: Relocation Task Detail and Provider Matching.
/// Provides advice for the task and direct actions to find or request nearby providers.
class TaskDetailView extends StatelessWidget {
  const TaskDetailView({super.key});

  static const route = '/assistant/task-detail';

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final task = args['task'] as PlanTask? ??
        const PlanTask(
          id: 't_demo',
          title: 'Install Water Purifier (RO)',
          description: 'Ensure clean drinking water on arrival. Municipal TDS in your area varies.',
          category: 'Plumber',
          phase: 'Day 1 Essentials',
          isCompleted: false,
        );
    final area = (args['area'] ?? 'Your Area').toString();

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: 'Task Details',
        bottomButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiMainButton(
              label: 'Request ${task.category} Service',
              customAccent: UiColors.indigo,
              onPressed: () {
                // Pre-fills category in Module 3 request form
                Navigator.pushNamed(
                  context,
                  '/requests/request-form',
                  arguments: {
                    'category': task.category,
                    'description': 'Relocation move-in setup in $area: ${task.title}',
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: UiColors.indigo),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Browse providers in Module 2
                Navigator.pushNamed(
                  context,
                  '/browse/listing-list',
                  arguments: {
                    'title': '${task.category} in $area',
                    'kind': 'service',
                    'category': task.category,
                  },
                );
              },
              child: uiText('Browse ${task.category}s on Map', size: 14, weight: FontWeight.w700, color: UiColors.indigo),
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: UiColors.indigo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: uiText(task.phase.toUpperCase(), size: 11, weight: FontWeight.w800, color: UiColors.indigo),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? UiColors.teal.withValues(alpha: 0.12)
                                : UiColors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: uiText(
                            task.isCompleted ? 'COMPLETED' : 'PENDING',
                            size: 11,
                            weight: FontWeight.w800,
                            color: task.isCompleted ? UiColors.teal : UiColors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    uiText(task.title, size: 20, weight: FontWeight.w800),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        uiText('Service Category: ', size: 13, color: UiColors.muted),
                        uiText(task.category, size: 13, weight: FontWeight.w700, color: UiColors.indigo),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description and Advice Card
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
                    uiText('Gemini AI Relocation Advice', size: 14.5, weight: FontWeight.w800),
                    const SizedBox(height: 8),
                    uiText(
                      task.description,
                      size: 13.5,
                      color: UiColors.ink,
                      height: 1.5,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: UiColors.bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: UiColors.indigo, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: uiText(
                              'Optimized for $area and local utility standards.',
                              size: 12,
                              color: UiColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/models/relocation_plan.dart';
import '../../../core/widgets/ui_kit.dart';
import '../data/assistant_repository.dart';
import 'new_to_city_form_view.dart';
import 'task_detail_view.dart';

/// Screen 4.8: Interactive Relocation Checklist.
/// Multi-phase move-in checklist with instant checkmark completion and task detail deep-links.
class ChecklistView extends StatefulWidget {
  const ChecklistView({super.key});

  static const route = '/assistant/checklist';

  @override
  State<ChecklistView> createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  final _repo = AssistantRepository();
  String _selectedPhase = 'All';
  late RelocationPlan _plan;
  bool _initialized = false;

  final _phases = ['All', 'Day 1 Essentials', 'Week 1 Setup', 'Utilities & Living'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
      _plan = args['plan'] as RelocationPlan? ??
          _repo.cachedPlan ??
          _repo.buildDefaultPlan(
            planId: 'demo_plan',
            uid: 'guest',
            area: 'Shivajinagar, Pune',
            household: 'General',
          );
      _initialized = true;
    }
  }

  void _toggleTask(PlanTask task) {
    final nextState = !task.isCompleted;
    final updatedList = _plan.tasks
        .map((t) => t.id == task.id ? t.copyWith(isCompleted: nextState) : t)
        .toList();

    setState(() {
      _plan = RelocationPlan(
        id: _plan.id,
        userId: _plan.userId,
        destinationArea: _plan.destinationArea,
        householdType: _plan.householdType,
        tasks: updatedList,
        updatedAt: DateTime.now(),
      );
    });

    _repo.toggleTaskCompletion(
      planId: _plan.id,
      allTasks: updatedList,
      taskId: task.id,
      isCompleted: nextState,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _selectedPhase == 'All'
        ? _plan.tasks
        : _plan.tasks.where((t) => t.phase.toLowerCase().contains(_selectedPhase.toLowerCase().split(' ').first)).toList();

    return Theme(
      data: uiFeatureTheme(context, UiColors.indigo),
      child: UiScaffold(
        title: '${_plan.destinationArea} Guide',
        trailing: IconButton(
          icon: const Icon(Icons.refresh_rounded, color: UiColors.indigo),
          tooltip: 'Regenerate Plan',
          onPressed: () {
            Navigator.pushReplacementNamed(context, NewToCityFormView.route);
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: UiColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: UiColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      uiText('Move-In Progress', size: 14, weight: FontWeight.w700),
                      const Spacer(),
                      uiText(
                        '${_plan.completedTasks} of ${_plan.totalTasks} Completed',
                        size: 13,
                        weight: FontWeight.w800,
                        color: UiColors.indigo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _plan.progress,
                      backgroundColor: UiColors.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(UiColors.indigo),
                      minHeight: 7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Phase Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final phase in _phases)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: UiChip(
                        label: phase,
                        isSelected: _selectedPhase == phase,
                        customAccent: UiColors.indigo,
                        onTap: () => setState(() => _selectedPhase = phase),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Task List
            Expanded(
              child: ListView.separated(
                itemCount: filteredTasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return _buildTaskCard(task);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(PlanTask task) {
    return Container(
      decoration: BoxDecoration(
        color: UiColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted ? UiColors.indigo.withValues(alpha: 0.3) : UiColors.line,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: UiColors.indigo,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (_) => _toggleTask(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? UiColors.muted : UiColors.ink,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: UiColors.indigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: uiText(task.category, size: 10.5, weight: FontWeight.w700, color: UiColors.indigo),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: uiText(
                  task.phase,
                  size: 11,
                  color: UiColors.muted,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: UiColors.muted),
        onTap: () {
          Navigator.pushNamed(
            context,
            TaskDetailView.route,
            arguments: {
              'task': task,
              'area': _plan.destinationArea,
            },
          );
        },
      ),
    );
  }
}

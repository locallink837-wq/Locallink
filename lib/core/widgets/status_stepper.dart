import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Progress step bar matching HTML spec (`.st` element).
/// Example: Open > Accepted > On the way > Done
class StatusStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStepIndex; // 0-indexed: steps up to currentStepIndex are active
  final Color activeColor;

  const StatusStepper({
    super.key,
    this.steps = const ['Open', 'Accepted', 'On the way', 'Done'],
    required this.currentStepIndex,
    this.activeColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentStepIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 2,
              right: index == steps.length - 1 ? 0 : 2,
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCompleted ? activeColor : AppColors.inputBorderLight,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: isCompleted ? FontWeight.w800 : FontWeight.w600,
                    color: isCompleted ? AppColors.inkLight : AppColors.secondaryMuteLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

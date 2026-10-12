import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Category Chip Pill (`.ch span` from HTML spec).
/// Pill-shaped tag with active and inactive styling (99px border radius).
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color activeColor;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.activeColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(AppDecorations.chipRadius),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.inputBorderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.inkLight,
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrollable or wrapping list of CategoryChips
class CategoryChipGroup extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String>? onSelected;
  final Color activeColor;

  const CategoryChipGroup({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.onSelected,
    this.activeColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: CategoryChip(
              label: cat,
              isSelected: isSelected,
              activeColor: activeColor,
              onTap: onSelected != null ? () => onSelected!(cat) : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

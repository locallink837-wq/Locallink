import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Item data for CategoryGrid
class CategoryGridItem {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const CategoryGridItem({
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
  });
}

/// Category Grid Widget matching the HTML spec (`.xg` element).
/// Shows 2-column or 3-column square cards with rounded avatar icon and bold title.
class CategoryGrid extends StatelessWidget {
  final List<CategoryGridItem> items;
  final int crossAxisCount;
  final double spacing;
  final Color defaultColor;

  const CategoryGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.spacing = 8.0,
    this.defaultColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: 1.35,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final color = item.color ?? defaultColor;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lineLight),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, size: 20, color: color),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

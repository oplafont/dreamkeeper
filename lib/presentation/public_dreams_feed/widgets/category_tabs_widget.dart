import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class CategoryTabsWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTabsWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'id': 'all', 'name': 'All Dreams', 'icon': Icons.grid_view},
      {'id': 'trending', 'name': 'Trending', 'icon': Icons.trending_up},
      {'id': 'lucid', 'name': 'Lucid', 'icon': Icons.lightbulb_outline},
      {'id': 'nightmares', 'name': 'Nightmares', 'icon': Icons.nightlight},
      {'id': 'recurring', 'name': 'Recurring', 'icon': Icons.repeat},
      {'id': 'prophetic', 'name': 'Prophetic', 'icon': Icons.auto_awesome},
    ];

    return Container(
      height: 12.h,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryBurgundy.withAlpha(204),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderPurple.withAlpha(77),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['id'];

          return GestureDetector(
            onTap: () => onCategorySelected(category['id'] as String),
            child: Container(
              margin: EdgeInsets.only(right: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppTheme.coralRed : AppTheme.cardMediumPurple,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.coralRed
                      : AppTheme.borderPurple.withAlpha(77),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    color: AppTheme.textWhite,
                    size: 24,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 11.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class SortOptionsWidget extends StatelessWidget {
  final String selectedSortOption;
  final Function(String) onSortOptionSelected;

  const SortOptionsWidget({
    super.key,
    required this.selectedSortOption,
    required this.onSortOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'id': 'trending', 'name': 'Trending', 'icon': Icons.trending_up},
      {'id': 'recent', 'name': 'Most Recent', 'icon': Icons.access_time},
      {'id': 'popular', 'name': 'Most Popular', 'icon': Icons.star},
      {'id': 'resonance', 'name': 'High Resonance', 'icon': Icons.favorite},
      {'id': 'views', 'name': 'Most Viewed', 'icon': Icons.visibility},
      {'id': 'relevant', 'name': 'Most Relevant', 'icon': Icons.auto_awesome},
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryBurgundy.withAlpha(230),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderPurple.withAlpha(77),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort By',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sortOptions.map((option) {
                final isSelected = selectedSortOption == option['id'];
                return GestureDetector(
                  onTap: () => onSortOptionSelected(option['id'] as String),
                  child: Container(
                    margin: EdgeInsets.only(right: 2.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.coralRed
                          : AppTheme.cardMediumPurple,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.coralRed
                            : AppTheme.borderPurple.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          option['icon'] as IconData,
                          color: AppTheme.textWhite,
                          size: 18,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          option['name'] as String,
                          style: TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

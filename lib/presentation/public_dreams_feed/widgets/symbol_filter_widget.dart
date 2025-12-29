import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SymbolFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const SymbolFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'All', 'icon': Icons.grid_view},
    {'id': 'flying', 'label': 'Flying', 'icon': Icons.flight},
    {'id': 'animals', 'label': 'Animals', 'icon': Icons.pets},
    {'id': 'people', 'label': 'People', 'icon': Icons.people},
    {'id': 'places', 'label': 'Places', 'icon': Icons.place},
    {'id': 'objects', 'label': 'Objects', 'icon': Icons.category},
    {'id': 'emotions', 'label': 'Emotions', 'icon': Icons.emoji_emotions},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkBurgundy.withAlpha(230),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderPurple.withAlpha(77),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = selectedFilter == filter['id'];
            return Padding(
              padding: EdgeInsets.only(right: 3.w),
              child: _buildFilterChip(
                label: filter['label'],
                icon: filter['icon'],
                isSelected: isSelected,
                onTap: () => onFilterSelected(filter['id']),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppTheme.accentRedPurple, AppTheme.coralRed],
                )
              : null,
          color: isSelected ? null : AppTheme.cardMediumPurple,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentRedPurple
                : AppTheme.borderPurple.withAlpha(128),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.accentRedPurple.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.textWhite : AppTheme.textMediumGray,
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.textWhite
                    : AppTheme.textMediumGray,
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

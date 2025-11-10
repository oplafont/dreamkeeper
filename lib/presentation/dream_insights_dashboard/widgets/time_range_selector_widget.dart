import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TimeRangeSelectorWidget extends StatelessWidget {
  final String selectedRange;
  final Function(String) onRangeChanged;

  const TimeRangeSelectorWidget({
    Key? key,
    required this.selectedRange,
    required this.onRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ranges = ['Week', 'Month', 'Year'];

    return Container(
      height: 6.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children:
            ranges.map((range) {
              final isSelected = selectedRange == range;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onRangeChanged(range),
                  child: Container(
                    margin: EdgeInsets.all(0.5.w),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        range,
                        style: AppTheme.lightTheme.textTheme.labelMedium
                            ?.copyWith(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .onSurfaceVariant,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

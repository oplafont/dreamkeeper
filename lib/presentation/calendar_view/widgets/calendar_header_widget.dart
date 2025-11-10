import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final String currentMonth;
  final bool isMonthView;
  final VoidCallback onToggleView;
  final VoidCallback onTodayPressed;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarHeaderWidget({
    super.key,
    required this.currentMonth,
    required this.isMonthView,
    required this.onToggleView,
    required this.onTodayPressed,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(
              alpha: 0.1,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onPreviousMonth,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'chevron_left',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    currentMonth,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  GestureDetector(
                    onTap: onNextMonth,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onTodayPressed,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Today',
                        style: AppTheme.lightTheme.textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: isMonthView ? null : onToggleView,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isMonthView
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Month',
                      style: AppTheme.lightTheme.textTheme.labelMedium
                          ?.copyWith(
                            color:
                                isMonthView
                                    ? Colors.white
                                    : AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: !isMonthView ? null : onToggleView,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          !isMonthView
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Week',
                      style: AppTheme.lightTheme.textTheme.labelMedium
                          ?.copyWith(
                            color:
                                !isMonthView
                                    ? Colors.white
                                    : AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

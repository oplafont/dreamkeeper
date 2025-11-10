import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StreakVisualizationWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final List<bool> last7Days;

  const StreakVisualizationWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.last7Days,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_fire_department',
                color:
                    currentStreak > 0
                        ? Colors.orange
                        : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Dream Journal Streak',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    currentStreak.toString(),
                    style: AppTheme.lightTheme.textTheme.headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              currentStreak > 0
                                  ? Colors.orange
                                  : AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurfaceVariant,
                        ),
                  ),
                  Text(
                    'Current',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.3,
                ),
              ),
              Column(
                children: [
                  Text(
                    longestStreak.toString(),
                    style: AppTheme.lightTheme.textTheme.headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.secondary,
                        ),
                  ),
                  Text(
                    'Best',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Last 7 Days',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final hasEntry =
                  index < last7Days.length ? last7Days[index] : false;
              return Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color:
                      hasEntry
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                  shape: BoxShape.circle,
                ),
                child:
                    hasEntry
                        ? Center(
                          child: CustomIconWidget(
                            iconName: 'check',
                            color: Colors.white,
                            size: 12,
                          ),
                        )
                        : null,
              );
            }),
          ),
          if (currentStreak >= 7) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.getSuccessColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'emoji_events',
                    color: AppTheme.getSuccessColor(),
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Week Warrior!',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.getSuccessColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
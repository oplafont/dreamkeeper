import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StreakAnalysisWidget extends StatelessWidget {
  const StreakAnalysisWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentStreak = 12;
    final longestStreak = 28;
    final totalEntries = 156;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_fire_department',
                size: 24,
                color: Colors.orange,
              ),
              SizedBox(width: 2.w),
              Text(
                'Journaling Streak',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStreakCard(
                  'Current Streak',
                  '$currentStreak days',
                  AppTheme.lightTheme.colorScheme.secondary,
                  CustomIconWidget(
                    iconName: 'trending_up',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStreakCard(
                  'Longest Streak',
                  '$longestStreak days',
                  Colors.green,
                  CustomIconWidget(
                    iconName: 'emoji_events',
                    size: 20,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildStreakCard(
            'Total Entries',
            '$totalEntries dreams',
            AppTheme.lightTheme.colorScheme.primary,
            CustomIconWidget(
              iconName: 'auto_stories',
              size: 20,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            isFullWidth: true,
          ),
          SizedBox(height: 3.h),
          _buildStreakCalendar(),
        ],
      ),
    );
  }

  Widget _buildStreakCard(
    String title,
    String value,
    Color color,
    Widget icon, {
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 7 Days',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final hasEntry = index < 5; // Mock data: last 5 days have entries
            final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

            return Column(
              children: [
                Text(
                  dayNames[index],
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color:
                        hasEntry
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child:
                      hasEntry
                          ? Center(
                            child: CustomIconWidget(
                              iconName: 'check',
                              size: 16,
                              color: Colors.white,
                            ),
                          )
                          : null,
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

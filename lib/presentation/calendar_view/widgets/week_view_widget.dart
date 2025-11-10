import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './dream_summary_card_widget.dart';

class WeekViewWidget extends StatelessWidget {
  final DateTime selectedWeek;
  final List<Map<String, dynamic>> weekDreams;
  final Function(Map<String, dynamic>) onDreamTap;

  const WeekViewWidget({
    super.key,
    required this.selectedWeek,
    required this.weekDreams,
    required this.onDreamTap,
  });

  List<DateTime> _getWeekDays(DateTime week) {
    final startOfWeek = week.subtract(Duration(days: week.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<Map<String, dynamic>> _getDreamsForDay(DateTime day) {
    return weekDreams.where((dream) {
      final dreamDate = dream['date'] as DateTime;
      return dreamDate.year == day.year &&
          dreamDate.month == day.month &&
          dreamDate.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays(selectedWeek);

    return Column(
      children: [
        // Week header with day names
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children:
                weekDays.map((day) {
                  final isToday =
                      DateTime.now().year == day.year &&
                      DateTime.now().month == day.month &&
                      DateTime.now().day == day.day;

                  return Expanded(
                    child: Column(
                      children: [
                        Text(
                          [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ][day.weekday - 1],
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                                color:
                                    AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        SizedBox(height: 0.5.h),
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color:
                                isToday
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : Colors.transparent,
                            shape: BoxShape.circle,
                            border:
                                isToday
                                    ? null
                                    : Border.all(
                                      color: AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                          ),
                          child: Center(
                            child: Text(
                              day.day.toString(),
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                    color:
                                        isToday
                                            ? Colors.white
                                            : AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
        SizedBox(height: 2.h),
        // Week timeline with dreams
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            itemCount: weekDays.length,
            itemBuilder: (context, index) {
              final day = weekDays[index];
              final dayDreams = _getDreamsForDay(day);
              final isToday =
                  DateTime.now().year == day.year &&
                  DateTime.now().month == day.month &&
                  DateTime.now().day == day.day;

              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date column
                    SizedBox(
                      width: 20.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isToday
                                      ? AppTheme.lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun',
                                  ][day.weekday - 1],
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color:
                                            isToday
                                                ? AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .primary
                                                : AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Text(
                                  day.day.toString(),
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color:
                                            isToday
                                                ? AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .primary
                                                : AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // Timeline line
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color:
                                dayDreams.isNotEmpty
                                    ? AppTheme.lightTheme.colorScheme.secondary
                                    : AppTheme.lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                        if (index < weekDays.length - 1)
                          Container(
                            width: 2,
                            height: 15.h,
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                      ],
                    ),
                    SizedBox(width: 3.w),
                    // Dreams column
                    Expanded(
                      child:
                          dayDreams.isEmpty
                              ? Container(
                                height: 6.h,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'No dreams recorded',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                        color:
                                            AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              )
                              : Column(
                                children:
                                    dayDreams
                                        .map(
                                          (dream) => DreamSummaryCardWidget(
                                            dreamEntry: dream,
                                            onTap: () => onDreamTap(dream),
                                          ),
                                        )
                                        .toList(),
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

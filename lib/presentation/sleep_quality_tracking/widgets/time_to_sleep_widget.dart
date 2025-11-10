import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TimeToSleepWidget extends StatelessWidget {
  final int minutes;
  final Function(int) onChanged;

  const TimeToSleepWidget({
    super.key,
    required this.minutes,
    required this.onChanged,
  });

  String _getTimeLabel(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hour${hours == 1 ? '' : 's'}';
      } else {
        return '$hours hour${hours == 1 ? '' : 's'} $remainingMinutes min';
      }
    }
  }

  Color _getTimeColor(int minutes) {
    if (minutes <= 20) return Colors.green;
    if (minutes <= 30) return Colors.yellow;
    if (minutes <= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getTimeIcon(int minutes) {
    if (minutes <= 20) return Icons.bedtime;
    if (minutes <= 30) return Icons.schedule;
    if (minutes <= 60) return Icons.access_time;
    return Icons.warning;
  }

  String _getAdvice(int minutes) {
    if (minutes <= 10) {
      return 'Excellent! You fall asleep very quickly.';
    } else if (minutes <= 20) {
      return 'Good sleep onset time. This is considered healthy.';
    } else if (minutes <= 30) {
      return 'Slightly longer than ideal. Try relaxation techniques.';
    } else if (minutes <= 60) {
      return 'Consider improving your bedtime routine or sleep environment.';
    } else {
      return 'This may indicate sleep difficulties. Consider consulting a sleep specialist.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryDarkPurple,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.borderPurple.withAlpha(128),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time to Fall Asleep',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 4.w),

          // Time Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getTimeIcon(minutes),
                color: _getTimeColor(minutes),
                size: 8.w,
              ),
              SizedBox(width: 3.w),
              Column(
                children: [
                  Text(
                    minutes.toString(),
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'minutes',
                    style: TextStyle(
                      color: _getTimeColor(minutes),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 4.w),

          // Time Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getTimeColor(minutes),
              inactiveTrackColor: AppTheme.borderPurple.withAlpha(64),
              thumbColor: _getTimeColor(minutes),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 3.w),
              overlayColor: _getTimeColor(minutes).withAlpha(64),
              trackHeight: 1.w,
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: _getTimeColor(minutes),
              valueIndicatorTextStyle: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Slider(
              value: minutes.toDouble(),
              min: 5.0,
              max: 120.0,
              divisions: 23, // 5-minute increments
              label: _getTimeLabel(minutes),
              onChanged: (value) => onChanged(value.round()),
            ),
          ),

          // Scale Labels
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '5 min\nVery Fast',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 9.sp,
                  ),
                ),
                Text(
                  '20 min\nNormal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 9.sp,
                  ),
                ),
                Text(
                  '60 min\nSlow',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 9.sp,
                  ),
                ),
                Text(
                  '120 min\nDifficulty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.w),

          // Quick Selection Buttons
          Wrap(
            spacing: 2.w,
            runSpacing: 2.w,
            children:
                [5, 10, 15, 20, 30, 45, 60, 90].map((timeMinutes) {
                  final isSelected = minutes == timeMinutes;
                  return GestureDetector(
                    onTap: () => onChanged(timeMinutes),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.5.w,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppTheme.accentPurple
                                : AppTheme.backgroundDarkest,
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppTheme.accentPurple
                                  : AppTheme.borderPurple.withAlpha(64),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${timeMinutes}m',
                        style: TextStyle(
                          color:
                              isSelected
                                  ? AppTheme.textWhite
                                  : AppTheme.textMediumGray,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          SizedBox(height: 3.w),

          // Advice Container
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDarkest,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: _getTimeColor(minutes).withAlpha(128),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: _getTimeColor(minutes),
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _getAdvice(minutes),
                    style: TextStyle(
                      color: AppTheme.textLightGray,
                      fontSize: 11.sp,
                      fontStyle: FontStyle.italic,
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
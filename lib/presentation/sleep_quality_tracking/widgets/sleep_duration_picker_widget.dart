import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SleepDurationPickerWidget extends StatelessWidget {
  final DateTime? bedtime;
  final DateTime? wakeTime;
  final Duration? sleepDuration;
  final Function(DateTime) onBedtimeChanged;
  final Function(DateTime) onWakeTimeChanged;

  const SleepDurationPickerWidget({
    super.key,
    this.bedtime,
    this.wakeTime,
    this.sleepDuration,
    required this.onBedtimeChanged,
    required this.onWakeTimeChanged,
  });

  void _showTimePicker(BuildContext context, bool isBedtime) {
    final DateTime initialTime =
        isBedtime
            ? (bedtime ?? DateTime.now().subtract(const Duration(hours: 8)))
            : (wakeTime ?? DateTime.now());

    if (Platform.isIOS) {
      _showCupertinoTimePicker(context, initialTime, isBedtime);
    } else {
      _showMaterialTimePicker(context, initialTime, isBedtime);
    }
  }

  void _showCupertinoTimePicker(
    BuildContext context,
    DateTime initialTime,
    bool isBedtime,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.primaryDarkPurple,
      builder:
          (context) => Container(
            height: 40.h,
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppTheme.textMediumGray,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    Text(
                      isBedtime ? 'Bedtime' : 'Wake Time',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: AppTheme.accentPurple,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: initialTime,
                    onDateTimeChanged: (DateTime newTime) {
                      if (isBedtime) {
                        onBedtimeChanged(newTime);
                      } else {
                        onWakeTimeChanged(newTime);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showMaterialTimePicker(
    BuildContext context,
    DateTime initialTime,
    bool isBedtime,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentPurple,
              onPrimary: AppTheme.textWhite,
              surface: AppTheme.primaryDarkPurple,
              onSurface: AppTheme.textWhite,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.primaryDarkPurple,
              hourMinuteTextColor: AppTheme.textWhite,
              dialHandColor: AppTheme.accentPurple,
              dialBackgroundColor: AppTheme.backgroundDarkest,
              entryModeIconColor: AppTheme.accentPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      if (isBedtime) {
        onBedtimeChanged(selectedDateTime);
      } else {
        onWakeTimeChanged(selectedDateTime);
      }
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Not set';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--';
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
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
            'Sleep Duration',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 4.w),

          // Sleep Duration Display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDarkest,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color:
                    sleepDuration != null
                        ? AppTheme.accentPurple.withAlpha(128)
                        : AppTheme.borderPurple.withAlpha(64),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Total Sleep Time',
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  _formatDuration(sleepDuration),
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.w),

          // Time Pickers Row
          Row(
            children: [
              // Bedtime Picker
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTimePicker(context, true),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color:
                            bedtime != null
                                ? AppTheme.accentPurple.withAlpha(128)
                                : AppTheme.borderPurple.withAlpha(64),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bedtime_outlined,
                          color: AppTheme.accentPurple,
                          size: 6.w,
                        ),
                        SizedBox(height: 2.w),
                        Text(
                          'Bedtime',
                          style: TextStyle(
                            color: AppTheme.textMediumGray,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 1.w),
                        Text(
                          _formatTime(bedtime),
                          style: TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Wake Time Picker
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTimePicker(context, false),
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color:
                            wakeTime != null
                                ? AppTheme.accentPurple.withAlpha(128)
                                : AppTheme.borderPurple.withAlpha(64),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined,
                          color: Colors.orange,
                          size: 6.w,
                        ),
                        SizedBox(height: 2.w),
                        Text(
                          'Wake Time',
                          style: TextStyle(
                            color: AppTheme.textMediumGray,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 1.w),
                        Text(
                          _formatTime(wakeTime),
                          style: TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Sleep Quality Indicator
          if (sleepDuration != null) ...[
            SizedBox(height: 3.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getSleepQualityIcon(),
                  color: _getSleepQualityColor(),
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  _getSleepQualityText(),
                  style: TextStyle(
                    color: _getSleepQualityColor(),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getSleepQualityIcon() {
    if (sleepDuration == null) return Icons.remove;
    final hours = sleepDuration!.inHours;
    if (hours >= 7 && hours <= 9) return Icons.check_circle;
    if (hours >= 6 && hours <= 10) return Icons.warning;
    return Icons.error;
  }

  Color _getSleepQualityColor() {
    if (sleepDuration == null) return AppTheme.textMediumGray;
    final hours = sleepDuration!.inHours;
    if (hours >= 7 && hours <= 9) return Colors.green;
    if (hours >= 6 && hours <= 10) return Colors.orange;
    return Colors.red;
  }

  String _getSleepQualityText() {
    if (sleepDuration == null) return '';
    final hours = sleepDuration!.inHours;
    if (hours >= 7 && hours <= 9) return 'Optimal sleep duration';
    if (hours >= 6 && hours <= 10) return 'Acceptable sleep duration';
    if (hours < 6) return 'Too little sleep';
    return 'Too much sleep';
  }
}
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BedtimeRitualWidget extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const BedtimeRitualWidget({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<BedtimeRitualWidget> createState() => _BedtimeRitualWidgetState();
}

class _BedtimeRitualWidgetState extends State<BedtimeRitualWidget> {
  late TimeOfDay _optimalBedtime;

  final List<int> _leadTimeOptions = [15, 30, 45, 60, 90];

  final List<Map<String, String>> _sleepHygieneTips = [
    {
      'tip': 'Keep your bedroom cool and dark',
      'category': 'Environment',
    },
    {
      'tip': 'Avoid screens 1 hour before bed',
      'category': 'Digital Wellness',
    },
    {
      'tip': 'Practice deep breathing exercises',
      'category': 'Relaxation',
    },
    {
      'tip': 'Keep a consistent sleep schedule',
      'category': 'Routine',
    },
    {
      'tip': 'Try gentle stretching or yoga',
      'category': 'Movement',
    },
  ];

  @override
  void initState() {
    super.initState();
    _parseOptimalBedtime();
  }

  void _parseOptimalBedtime() {
    final timeStr = widget.settings['optimalBedtime'] as String;
    final parts = timeStr.split(':');
    _optimalBedtime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDarkPurple,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.nights_stay,
                    color: AppTheme.accentPurpleLight,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bedtime Ritual Notifications',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Prepare your mind for better dream recall',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLightGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.settings['enabled'] ?? false,
                  onChanged: (value) => _updateSetting('enabled', value),
                ),
              ],
            ),

            if (widget.settings['enabled'] == true) ...[
              SizedBox(height: 3.h),
              Divider(color: AppTheme.borderPurple.withAlpha(77)),
              SizedBox(height: 3.h),

              // Optimal Bedtime
              _buildOptimalBedtime(),
              SizedBox(height: 3.h),

              // Wind-down Reminder
              _buildWindDownReminder(),
              SizedBox(height: 3.h),

              // Lead Time
              _buildLeadTime(),
              SizedBox(height: 3.h),

              // Sleep Hygiene Tips
              _buildSleepHygieneTips(),
              SizedBox(height: 3.h),

              // Weekend Different Schedule
              _buildWeekendDifferent(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptimalBedtime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimal Bedtime',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: _selectOptimalBedtime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppTheme.cardMediumPurple,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderPurple),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bedtime,
                  color: AppTheme.accentPurpleLight,
                ),
                SizedBox(width: 3.w),
                Text(
                  _optimalBedtime.format(context),
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLightGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: AppTheme.textMediumGray,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.psychology,
                color: AppTheme.successColor,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Based on your sleep patterns, this gives you 8 hours of rest',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLightGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWindDownReminder() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardMediumPurple.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.settings['windDownReminder'] == true
              ? AppTheme.accentPurpleLight.withAlpha(128)
              : AppTheme.borderPurple.withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.self_improvement,
            color: AppTheme.accentPurpleLight,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wind-down Reminder',
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Gentle reminder to start your bedtime routine',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLightGray,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.settings['windDownReminder'] ?? false,
            onChanged: (value) => _updateSetting('windDownReminder', value),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wind-down Lead Time',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'How early should we remind you before your optimal bedtime?',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumGray,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _leadTimeOptions.map((minutes) {
            final isSelected = widget.settings['leadTime'] == minutes;
            return GestureDetector(
              onTap: () => _updateSetting('leadTime', minutes),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentPurple
                      : AppTheme.cardMediumPurple,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentPurpleLight
                        : AppTheme.borderPurple,
                  ),
                ),
                child: Text(
                  '${minutes}m',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.textWhite
                        : AppTheme.textLightGray,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSleepHygieneTips() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardMediumPurple.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.settings['sleepHygieneTips'] == true
              ? AppTheme.accentPurpleLight.withAlpha(128)
              : AppTheme.borderPurple.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accentPurpleLight,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Hygiene Tips',
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Include helpful tips in bedtime notifications',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLightGray,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.settings['sleepHygieneTips'] ?? false,
                onChanged: (value) => _updateSetting('sleepHygieneTips', value),
              ),
            ],
          ),
          if (widget.settings['sleepHygieneTips'] == true) ...[
            SizedBox(height: 2.h),
            Text(
              'Example Tips:',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLightGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Column(
              children: _sleepHygieneTips.take(3).map((tip) {
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tip['category']!,
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.accentPurpleLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          tip['tip']!,
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLightGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekendDifferent() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardMediumPurple.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderPurple.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.weekend,
                color: AppTheme.accentPurpleLight,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekend Schedule',
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Use different bedtime for weekends',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLightGray,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.settings['weekendDifferent'] ?? false,
                onChanged: (value) => _updateSetting('weekendDifferent', value),
              ),
            ],
          ),
          if (widget.settings['weekendDifferent'] == true) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Maintaining consistent sleep schedule is recommended for better dream recall',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLightGray,
                      ),
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

  Future<void> _selectOptimalBedtime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _optimalBedtime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.accentPurpleLight,
              onPrimary: AppTheme.textWhite,
              surface: AppTheme.cardDarkPurple,
              onSurface: AppTheme.textLightGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _optimalBedtime) {
      setState(() {
        _optimalBedtime = picked;
      });
      final timeStr =
          '${_optimalBedtime.hour.toString().padLeft(2, '0')}:${_optimalBedtime.minute.toString().padLeft(2, '0')}';
      _updateSetting('optimalBedtime', timeStr);
    }
  }

  void _updateSetting(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(widget.settings);
    updatedSettings[key] = value;
    widget.onSettingsChanged(updatedSettings);
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MorningDreamCaptureWidget extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const MorningDreamCaptureWidget({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<MorningDreamCaptureWidget> createState() =>
      _MorningDreamCaptureWidgetState();
}

class _MorningDreamCaptureWidgetState extends State<MorningDreamCaptureWidget> {
  late TimeOfDay _reminderTime;

  final List<Map<String, dynamic>> _toneOptions = [
    {
      'key': 'soft_chime',
      'name': 'Soft Chime',
      'description': 'Gentle bell sound'
    },
    {
      'key': 'nature_sounds',
      'name': 'Nature Sounds',
      'description': 'Birds and water'
    },
    {
      'key': 'piano_melody',
      'name': 'Piano Melody',
      'description': 'Calming piano notes'
    },
    {
      'key': 'wind_chimes',
      'name': 'Wind Chimes',
      'description': 'Ethereal chimes'
    },
    {
      'key': 'sunrise_tone',
      'name': 'Sunrise Tone',
      'description': 'Warm awakening sound'
    },
  ];

  final List<int> _snoozeDurations = [5, 10, 15, 20, 30];

  @override
  void initState() {
    super.initState();
    _parseReminderTime();
  }

  void _parseReminderTime() {
    final timeStr = widget.settings['reminderTime'] as String;
    final parts = timeStr.split(':');
    _reminderTime = TimeOfDay(
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
                    Icons.wb_sunny,
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
                        'Morning Dream Capture',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Gentle reminders to record your dreams',
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

              // Reminder Time
              _buildTimeSelector(),
              SizedBox(height: 3.h),

              // Smart Wake Detection
              _buildSmartWakeDetection(),
              SizedBox(height: 3.h),

              // Snooze Duration
              _buildSnoozeDuration(),
              SizedBox(height: 3.h),

              // Notification Tone
              _buildNotificationTone(),
              SizedBox(height: 3.h),

              // Weekdays Only Option
              _buildWeekdaysOnly(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Time',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: _selectReminderTime,
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
                  Icons.access_time,
                  color: AppTheme.accentPurpleLight,
                ),
                SizedBox(width: 3.w),
                Text(
                  _reminderTime.format(context),
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
        Text(
          'Best time to catch your dreams before they fade',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartWakeDetection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardMediumPurple.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.settings['smartWakeDetection'] == true
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
                Icons.psychology,
                color: AppTheme.accentPurpleLight,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Wake Detection',
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Uses sleep patterns to avoid deep sleep interruption',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLightGray,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.settings['smartWakeDetection'] ?? false,
                onChanged: (value) =>
                    _updateSetting('smartWakeDetection', value),
              ),
            ],
          ),
          if (widget.settings['smartWakeDetection'] == true) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.accentPurpleLight,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Will notify within ±30 minutes of set time during light sleep phases',
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

  Widget _buildSnoozeDuration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Snooze Duration',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _snoozeDurations.map((duration) {
            final isSelected = widget.settings['snoozeDuration'] == duration;
            return GestureDetector(
              onTap: () => _updateSetting('snoozeDuration', duration),
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
                  '${duration}m',
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

  Widget _buildNotificationTone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Tone',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardMediumPurple,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderPurple),
          ),
          child: Column(
            children: _toneOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final tone = entry.value;
              final isSelected = widget.settings['gentleTone'] == tone['key'];
              final isLast = index == _toneOptions.length - 1;

              return InkWell(
                onTap: () => _updateSetting('gentleTone', tone['key']),
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? Radius.circular(12) : Radius.zero,
                  bottom: isLast ? Radius.circular(12) : Radius.zero,
                ),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    border: !isLast
                        ? Border(
                            bottom: BorderSide(
                            color: AppTheme.borderPurple.withAlpha(77),
                          ))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: tone['key'],
                        groupValue: widget.settings['gentleTone'],
                        onChanged: (value) =>
                            _updateSetting('gentleTone', value),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tone['name'],
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textLightGray,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              tone['description'],
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textMediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.play_circle_outline,
                          color: AppTheme.accentPurpleLight,
                        ),
                        onPressed: () => _playTonePreview(tone['key']),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdaysOnly() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardMediumPurple.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderPurple.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: AppTheme.accentPurpleLight,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekdays Only',
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Skip notifications on weekends',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLightGray,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.settings['weekdaysOnly'] ?? false,
            onChanged: (value) => _updateSetting('weekdaysOnly', value),
          ),
        ],
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
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

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      final timeStr =
          '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
      _updateSetting('reminderTime', timeStr);
    }
  }

  void _playTonePreview(String toneKey) {
    // Simulate tone preview
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Playing preview: ${_toneOptions.firstWhere((t) => t['key'] == toneKey)['name']}',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        backgroundColor: AppTheme.accentPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _updateSetting(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(widget.settings);
    updatedSettings[key] = value;
    widget.onSettingsChanged(updatedSettings);
  }
}

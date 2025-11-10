import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class QuickSetupWizardWidget extends StatefulWidget {
  final Function(Map<String, Map<String, dynamic>>) onCompleted;

  const QuickSetupWizardWidget({
    super.key,
    required this.onCompleted,
  });

  @override
  State<QuickSetupWizardWidget> createState() => _QuickSetupWizardWidgetState();
}

class _QuickSetupWizardWidgetState extends State<QuickSetupWizardWidget> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Wizard data
  Map<String, dynamic> _wizardData = {
    'sleepSchedule': 'regular', // regular, irregular, shift_work
    'wakeUpTime': '07:30',
    'bedTime': '23:00',
    'dreamRecallGoal': 'improve', // improve, maintain, occasional
    'notificationPreference': 'gentle', // gentle, standard, minimal
    'scheduleType':
        'weekdays_same', // weekdays_same, weekends_different, always_same
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with progress
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkPurple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.textMediumGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),

                // Title and progress
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.accentPurpleLight,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Quick Setup Wizard',
                      style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${_currentStep + 1}/$_totalSteps',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMediumGray,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                // Progress bar
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _totalSteps,
                  backgroundColor: AppTheme.borderPurple.withAlpha(77),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.accentPurpleLight),
                ),
              ],
            ),
          ),

          // Wizard content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildSleepScheduleStep(),
                _buildTimingStep(),
                _buildGoalsStep(),
                _buildPreferencesStep(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkPurple,
              border: Border(
                top: BorderSide(
                  color: AppTheme.borderPurple.withAlpha(77),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 4.w),
                Expanded(
                  flex: _currentStep > 0 ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: _currentStep < _totalSteps - 1
                        ? _nextStep
                        : _completeWizard,
                    child: Text(_currentStep < _totalSteps - 1
                        ? 'Next'
                        : 'Complete Setup'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepScheduleStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛏️ Sleep Schedule',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Help us understand your sleep patterns to optimize notification timing.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLightGray,
            ),
          ),
          SizedBox(height: 4.h),
          _buildScheduleOption(
            'regular',
            '🌅 Regular Schedule',
            'I go to bed and wake up at consistent times',
            'Most people - consistent daily routine',
          ),
          SizedBox(height: 2.h),
          _buildScheduleOption(
            'irregular',
            '🔄 Irregular Schedule',
            'My sleep times vary day to day',
            'Flexible schedule - we\'ll adapt dynamically',
          ),
          SizedBox(height: 2.h),
          _buildScheduleOption(
            'shift_work',
            '🌃 Shift Work',
            'I work different shifts or night hours',
            'Special optimization for shift workers',
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleOption(
      String key, String title, String subtitle, String description) {
    final isSelected = _wizardData['sleepSchedule'] == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _wizardData['sleepSchedule'] = key;
        });
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentPurple.withAlpha(26)
              : AppTheme.cardDarkPurple,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppTheme.accentPurpleLight : AppTheme.borderPurple,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: key,
              groupValue: _wizardData['sleepSchedule'],
              onChanged: (value) {
                setState(() {
                  _wizardData['sleepSchedule'] = value;
                });
              },
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textWhite,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLightGray,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    description,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⏰ Sleep Timing',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'When do you typically sleep and wake up?',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLightGray,
            ),
          ),
          SizedBox(height: 4.h),

          // Wake up time
          _buildTimeSelector(
            'Wake Up Time',
            'wakeUpTime',
            Icons.wb_sunny,
            'When you usually wake up',
          ),
          SizedBox(height: 3.h),

          // Bed time
          _buildTimeSelector(
            'Bed Time',
            'bedTime',
            Icons.nights_stay,
            'When you usually go to bed',
          ),
          SizedBox(height: 4.h),

          // Weekend schedule
          _buildScheduleTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
      String label, String key, IconData icon, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: () => _selectTime(key),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkPurple,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderPurple),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.accentPurpleLight,
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(_wizardData[key]),
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textLightGray,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumGray,
                      ),
                    ),
                  ],
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
      ],
    );
  }

  Widget _buildScheduleTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekend Schedule',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 2.h),
        _buildScheduleTypeOption(
          'always_same',
          'Same Every Day',
          'Consistent schedule all week',
        ),
        SizedBox(height: 1.h),
        _buildScheduleTypeOption(
          'weekends_different',
          'Different on Weekends',
          'Later sleep/wake times on weekends',
        ),
        SizedBox(height: 1.h),
        _buildScheduleTypeOption(
          'weekdays_same',
          'Weekdays Only',
          'Skip notifications on weekends',
        ),
      ],
    );
  }

  Widget _buildScheduleTypeOption(String key, String title, String subtitle) {
    final isSelected = _wizardData['scheduleType'] == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _wizardData['scheduleType'] = key;
        });
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentPurple.withAlpha(26)
              : AppTheme.cardMediumPurple,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentPurpleLight
                : AppTheme.borderPurple.withAlpha(128),
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: key,
              groupValue: _wizardData['scheduleType'],
              onChanged: (value) {
                setState(() {
                  _wizardData['scheduleType'] = value;
                });
              },
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLightGray,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Dream Goals',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'What\'s your main goal with dream journaling?',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLightGray,
            ),
          ),
          SizedBox(height: 4.h),
          _buildGoalOption(
            'improve',
            '📈 Improve Dream Recall',
            'I want to remember more dreams',
            'More frequent reminders and tips',
          ),
          SizedBox(height: 2.h),
          _buildGoalOption(
            'maintain',
            '🔄 Maintain Current Practice',
            'I already remember dreams well',
            'Balanced notification frequency',
          ),
          SizedBox(height: 2.h),
          _buildGoalOption(
            'occasional',
            '🌙 Occasional Journaling',
            'I journal dreams when they happen',
            'Minimal, gentle reminders only',
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption(
      String key, String title, String subtitle, String description) {
    final isSelected = _wizardData['dreamRecallGoal'] == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _wizardData['dreamRecallGoal'] = key;
        });
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentPurple.withAlpha(26)
              : AppTheme.cardDarkPurple,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppTheme.accentPurpleLight : AppTheme.borderPurple,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: key,
              groupValue: _wizardData['dreamRecallGoal'],
              onChanged: (value) {
                setState(() {
                  _wizardData['dreamRecallGoal'] = value;
                });
              },
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textWhite,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLightGray,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    description,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔔 Notification Style',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'How would you like to be notified?',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLightGray,
            ),
          ),
          SizedBox(height: 4.h),

          _buildPreferenceOption(
            'gentle',
            '🌸 Gentle & Mindful',
            'Soft tones, encouraging messages',
            'Perfect for sensitive sleepers',
          ),
          SizedBox(height: 2.h),

          _buildPreferenceOption(
            'standard',
            '🔔 Standard Notifications',
            'Regular tones, clear reminders',
            'Balanced approach for most users',
          ),
          SizedBox(height: 2.h),

          _buildPreferenceOption(
            'minimal',
            '📱 Minimal & Discrete',
            'Simple alerts, no sounds',
            'For those who prefer subtle reminders',
          ),

          SizedBox(height: 4.h),

          // Summary
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.accentPurple.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.accentPurpleLight,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Ready to Begin!',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'We\'ll create personalized notification settings based on your preferences. You can always adjust these later in the settings.',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLightGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceOption(
      String key, String title, String subtitle, String description) {
    final isSelected = _wizardData['notificationPreference'] == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          _wizardData['notificationPreference'] = key;
        });
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentPurple.withAlpha(26)
              : AppTheme.cardDarkPurple,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppTheme.accentPurpleLight : AppTheme.borderPurple,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: key,
              groupValue: _wizardData['notificationPreference'],
              onChanged: (value) {
                setState(() {
                  _wizardData['notificationPreference'] = value;
                });
              },
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textWhite,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLightGray,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    description,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _selectTime(String key) async {
    final currentTime = _wizardData[key] as String;
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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

    if (picked != null) {
      setState(() {
        _wizardData[key] =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeWizard() {
    // Convert wizard data to notification settings
    final settings = _generateSettingsFromWizard();
    widget.onCompleted(settings);
    Navigator.of(context).pop();
  }

  Map<String, Map<String, dynamic>> _generateSettingsFromWizard() {
    return {
      'morning': {
        'enabled': _wizardData['dreamRecallGoal'] != 'occasional',
        'reminderTime': _wizardData['wakeUpTime'],
        'smartWakeDetection': _wizardData['sleepSchedule'] == 'regular',
        'weekdaysOnly': _wizardData['scheduleType'] == 'weekdays_same',
        'gentleTone': _wizardData['notificationPreference'] == 'gentle'
            ? 'soft_chime'
            : 'nature_sounds',
      },
      'bedtime': {
        'enabled': _wizardData['dreamRecallGoal'] == 'improve',
        'optimalBedtime': _wizardData['bedTime'],
        'windDownReminder': true,
        'leadTime': _wizardData['dreamRecallGoal'] == 'improve' ? 30 : 15,
        'sleepHygieneTips': _wizardData['dreamRecallGoal'] == 'improve',
      },
      'weekly': {
        'enabled': _wizardData['dreamRecallGoal'] != 'occasional',
        'frequency': 'weekly',
        'deliveryDay': 'sunday',
        'contentDepth':
            _wizardData['dreamRecallGoal'] == 'improve' ? 'detailed' : 'brief',
        'includeInsights': true,
      },
    };
  }
}

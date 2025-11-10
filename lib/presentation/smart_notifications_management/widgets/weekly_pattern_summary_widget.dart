import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WeeklyPatternSummaryWidget extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const WeeklyPatternSummaryWidget({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<WeeklyPatternSummaryWidget> createState() =>
      _WeeklyPatternSummaryWidgetState();
}

class _WeeklyPatternSummaryWidgetState
    extends State<WeeklyPatternSummaryWidget> {
  late TimeOfDay _deliveryTime;

  final List<Map<String, String>> _frequencyOptions = [
    {
      'key': 'weekly',
      'name': 'Weekly',
      'description': 'Every week on selected day'
    },
    {'key': 'bi-weekly', 'name': 'Bi-weekly', 'description': 'Every two weeks'},
    {
      'key': 'monthly',
      'name': 'Monthly',
      'description': 'First week of each month'
    },
  ];

  final List<Map<String, String>> _dayOptions = [
    {'key': 'monday', 'name': 'Monday', 'emoji': '🌅'},
    {'key': 'tuesday', 'name': 'Tuesday', 'emoji': '🌟'},
    {'key': 'wednesday', 'name': 'Wednesday', 'emoji': '⚡'},
    {'key': 'thursday', 'name': 'Thursday', 'emoji': '🌸'},
    {'key': 'friday', 'name': 'Friday', 'emoji': '🎉'},
    {'key': 'saturday', 'name': 'Saturday', 'emoji': '🌈'},
    {'key': 'sunday', 'name': 'Sunday', 'emoji': '🌙'},
  ];

  final List<Map<String, String>> _contentDepthOptions = [
    {
      'key': 'brief',
      'name': 'Brief',
      'description': 'Key highlights and patterns'
    },
    {
      'key': 'detailed',
      'name': 'Detailed',
      'description': 'In-depth analysis and insights'
    },
    {
      'key': 'comprehensive',
      'name': 'Comprehensive',
      'description': 'Full report with recommendations'
    },
  ];

  @override
  void initState() {
    super.initState();
    _parseDeliveryTime();
  }

  void _parseDeliveryTime() {
    final timeStr = widget.settings['deliveryTime'] as String;
    final parts = timeStr.split(':');
    _deliveryTime = TimeOfDay(
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
                    Icons.analytics,
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
                        'Weekly Pattern Summary',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Personalized insights and dream analysis',
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

              // Frequency Selection
              _buildFrequencySelection(),
              SizedBox(height: 3.h),

              // Delivery Day
              _buildDeliveryDay(),
              SizedBox(height: 3.h),

              // Delivery Time
              _buildDeliveryTime(),
              SizedBox(height: 3.h),

              // Content Depth
              _buildContentDepth(),
              SizedBox(height: 3.h),

              // Include Insights
              _buildIncludeInsights(),
              SizedBox(height: 3.h),

              // Preview Sample
              _buildPreviewSample(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Frequency',
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
            children: _frequencyOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = widget.settings['frequency'] == option['key'];
              final isLast = index == _frequencyOptions.length - 1;

              return InkWell(
                onTap: () => _updateSetting('frequency', option['key']),
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? Radius.circular(12) : Radius.zero,
                  bottom: isLast ? Radius.circular(12) : Radius.zero,
                ),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppTheme.accentPurple.withAlpha(26) : null,
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
                        value: option['key']!,
                        groupValue: widget.settings['frequency'],
                        onChanged: (value) =>
                            _updateSetting('frequency', value),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['name']!,
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textLightGray,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              option['description']!,
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
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
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryDay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Day',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'When would you like to receive your dream insights?',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumGray,
          ),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 1.h,
            childAspectRatio: 3,
          ),
          itemCount: _dayOptions.length,
          itemBuilder: (context, index) {
            final day = _dayOptions[index];
            final isSelected = widget.settings['deliveryDay'] == day['key'];

            return GestureDetector(
              onTap: () => _updateSetting('deliveryDay', day['key']),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentPurple
                      : AppTheme.cardMediumPurple,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentPurpleLight
                        : AppTheme.borderPurple,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day['emoji']!,
                      style: TextStyle(fontSize: 5.w),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      day['name']!,
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppTheme.textWhite
                            : AppTheme.textLightGray,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeliveryTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Time',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 1.h),
        InkWell(
          onTap: _selectDeliveryTime,
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
                  Icons.schedule,
                  color: AppTheme.accentPurpleLight,
                ),
                SizedBox(width: 3.w),
                Text(
                  _deliveryTime.format(context),
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLightGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  _getTimeDescription(),
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMediumGray,
                  ),
                ),
                SizedBox(width: 2.w),
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

  Widget _buildContentDepth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Depth',
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'How detailed should your insights be?',
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumGray,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children: _contentDepthOptions.map((option) {
            final isSelected = widget.settings['contentDepth'] == option['key'];

            return Container(
              margin: EdgeInsets.only(bottom: 1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentPurple.withAlpha(26)
                    : AppTheme.cardMediumPurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accentPurpleLight
                      : AppTheme.borderPurple,
                ),
              ),
              child: RadioListTile<String>(
                value: option['key']!,
                groupValue: widget.settings['contentDepth'],
                onChanged: (value) => _updateSetting('contentDepth', value),
                title: Text(
                  option['name']!,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLightGray,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  option['description']!,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMediumGray,
                  ),
                ),
                activeColor: AppTheme.accentPurpleLight,
                contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIncludeInsights() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardMediumPurple.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.settings['includeInsights'] == true
              ? AppTheme.accentPurpleLight.withAlpha(128)
              : AppTheme.borderPurple.withAlpha(77),
        ),
      ),
      child: Row(
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
                  'AI-Powered Insights',
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Include AI analysis and pattern recognition',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLightGray,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.settings['includeInsights'] ?? false,
            onChanged: (value) => _updateSetting('includeInsights', value),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSample() {
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
                Icons.preview,
                color: AppTheme.accentPurpleLight,
              ),
              SizedBox(width: 2.w),
              Text(
                'Sample Weekly Summary',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDarkest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌙 Your Dream Journey This Week',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '📊 7 dreams recorded • 85% recall accuracy\n🎭 Recurring themes: Flying, Water, Family\n💫 Emotional patterns: 60% positive, 25% neutral\n🧠 AI Insight: Your dreams show increased creativity this week!',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLightGray,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeDescription() {
    final hour = _deliveryTime.hour;
    if (hour >= 6 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }

  Future<void> _selectDeliveryTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _deliveryTime,
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

    if (picked != null && picked != _deliveryTime) {
      setState(() {
        _deliveryTime = picked;
      });
      final timeStr =
          '${_deliveryTime.hour.toString().padLeft(2, '0')}:${_deliveryTime.minute.toString().padLeft(2, '0')}';
      _updateSetting('deliveryTime', timeStr);
    }
  }

  void _updateSetting(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(widget.settings);
    updatedSettings[key] = value;
    widget.onSettingsChanged(updatedSettings);
  }
}

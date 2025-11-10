import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SmartTimingAlgorithmsWidget extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const SmartTimingAlgorithmsWidget({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SmartTimingAlgorithmsWidget> createState() =>
      _SmartTimingAlgorithmsWidgetState();
}

class _SmartTimingAlgorithmsWidgetState
    extends State<SmartTimingAlgorithmsWidget> {
  final List<Map<String, dynamic>> _algorithmFeatures = [
    {
      'key': 'behaviorAnalysis',
      'name': 'Behavior Analysis',
      'description':
          'Learn your daily patterns and optimize notification timing',
      'icon': Icons.analytics,
      'benefits': [
        'Adapts to your schedule',
        'Improves over time',
        'Personalized timing'
      ],
    },
    {
      'key': 'meetingAvoidance',
      'name': 'Meeting Avoidance',
      'description': 'Avoid sending notifications during calendar events',
      'icon': Icons.event_busy,
      'benefits': [
        'Calendar integration',
        'Focus protection',
        'Smart scheduling'
      ],
    },
    {
      'key': 'sleepAvoidance',
      'name': 'Sleep Period Protection',
      'description': 'Never disturb you during detected sleep hours',
      'icon': Icons.bedtime,
      'benefits': [
        'Sleep tracking',
        'Natural wake detection',
        'Respect rest time'
      ],
    },
    {
      'key': 'locationBased',
      'name': 'Location-Based Timing',
      'description': 'Adjust notifications based on your location',
      'icon': Icons.location_on,
      'benefits': ['Travel adaptation', 'Context awareness', 'Geo-fencing'],
    },
    {
      'key': 'dndRespect',
      'name': 'Do Not Disturb Respect',
      'description': 'Honor system and app Do Not Disturb settings',
      'icon': Icons.do_not_disturb,
      'benefits': [
        'System integration',
        'Custom quiet hours',
        'Urgent override'
      ],
    },
  ];

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
                    Icons.psychology,
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
                        'Smart Timing Algorithms',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'AI-powered notification optimization',
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

              // Algorithm Features
              Column(
                children: _algorithmFeatures.map((feature) {
                  return _buildAlgorithmFeature(feature);
                }).toList(),
              ),

              SizedBox(height: 3.h),

              // Learning Progress
              _buildLearningProgress(),
              SizedBox(height: 3.h),

              // Performance Metrics
              _buildPerformanceMetrics(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmFeature(Map<String, dynamic> feature) {
    final isEnabled = widget.settings[feature['key']] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isEnabled
            ? AppTheme.accentPurple.withAlpha(26)
            : AppTheme.cardMediumPurple.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
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
                feature['icon'] as IconData,
                color: AppTheme.accentPurpleLight,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['name'],
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      feature['description'],
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLightGray,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) => _updateSetting(feature['key'], value),
              ),
            ],
          ),
          if (isEnabled) ...[
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: (feature['benefits'] as List<String>).map((benefit) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withAlpha(51),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    benefit,
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.accentPurpleLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLearningProgress() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardMediumPurple.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderPurple.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: AppTheme.accentPurpleLight,
              ),
              SizedBox(width: 2.w),
              Text(
                'Learning Progress',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Column(
            children: [
              _buildProgressItem(
                  'Behavior Pattern Recognition', 0.75, '3 weeks of data'),
              SizedBox(height: 1.h),
              _buildProgressItem(
                  'Optimal Timing Detection', 0.60, '2 weeks of data'),
              SizedBox(height: 1.h),
              _buildProgressItem(
                  'Context Understanding', 0.45, '1 week of data'),
            ],
          ),
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
                  Icons.lightbulb_outline,
                  color: AppTheme.accentPurpleLight,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'AI learns from your interactions to improve notification timing accuracy',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLightGray,
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

  Widget _buildProgressItem(String label, double progress, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLightGray,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.accentPurpleLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.borderPurple.withAlpha(77),
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentPurpleLight),
        ),
        SizedBox(height: 0.5.h),
        Text(
          subtitle,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
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
                Icons.trending_up,
                color: AppTheme.accentPurpleLight,
              ),
              SizedBox(width: 2.w),
              Text(
                'Performance Metrics',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Engagement Rate',
                  '89%',
                  'Last 7 days',
                  AppTheme.successColor,
                  Icons.thumb_up_outlined,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildMetricCard(
                  'Perfect Timing',
                  '73%',
                  'This month',
                  AppTheme.accentPurpleLight,
                  Icons.access_time,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Interruption Rate',
                  '12%',
                  'Down 5%',
                  AppTheme.warningColor,
                  Icons.block,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildMetricCard(
                  'Response Time',
                  '2.3m',
                  'Average',
                  AppTheme.accentPurple,
                  Icons.speed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 4.w,
              ),
              Spacer(),
              Text(
                value,
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textLightGray,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.textMediumGray,
            ),
          ),
        ],
      ),
    );
  }

  void _updateSetting(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(widget.settings);
    updatedSettings[key] = value;
    widget.onSettingsChanged(updatedSettings);
  }
}

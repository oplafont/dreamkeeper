import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SleepSuggestionsWidget extends StatelessWidget {
  final Duration? sleepDuration;
  final double sleepQuality;
  final int interruptions;

  const SleepSuggestionsWidget({
    super.key,
    this.sleepDuration,
    required this.sleepQuality,
    required this.interruptions,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = _generateSuggestions();
    final optimalTimes = _generateOptimalTimes();

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
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accentPurple,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Smart Suggestions',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.w),

          // Personalized Suggestions
          if (suggestions.isNotEmpty) ...[
            Text(
              'Based on your patterns:',
              style: TextStyle(
                color: AppTheme.textLightGray,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 2.w),

            ...suggestions.map(
              (suggestion) => _buildSuggestionItem(suggestion),
            ),

            SizedBox(height: 4.w),
          ],

          // Optimal Sleep Window
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkPurple,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: Colors.blue.withAlpha(128), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue, size: 4.w),
                    SizedBox(width: 2.w),
                    Text(
                      'Optimal Sleep Windows',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.w),

                ...optimalTimes.map(
                  (time) => Padding(
                    padding: EdgeInsets.only(bottom: 1.w),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: AppTheme.textLightGray,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.w),

          // Sleep Hygiene Tips
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkPurple,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: Colors.green.withAlpha(128), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.self_improvement,
                      color: Colors.green,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Sleep Hygiene Recommendations',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.w),

                ..._getGeneralSleepTips().map(
                  (tip) => Padding(
                    padding: EdgeInsets.only(bottom: 1.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11.sp,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              color: AppTheme.textLightGray,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSuggestionItem(SleepSuggestion suggestion) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkPurple,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: suggestion.color.withAlpha(128), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(suggestion.icon, color: suggestion.color, size: 4.w),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.title,
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  suggestion.description,
                  style: TextStyle(
                    color: AppTheme.textLightGray,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<SleepSuggestion> _generateSuggestions() {
    List<SleepSuggestion> suggestions = [];

    // Sleep duration suggestions
    if (sleepDuration != null) {
      final hours = sleepDuration!.inHours;
      if (hours < 6) {
        suggestions.add(
          SleepSuggestion(
            icon: Icons.access_time,
            color: Colors.red,
            title: 'Increase Sleep Duration',
            description:
                'You\'re getting less than 6 hours. Aim for 7-9 hours for optimal health and dream recall.',
          ),
        );
      } else if (hours > 10) {
        suggestions.add(
          SleepSuggestion(
            icon: Icons.schedule,
            color: Colors.orange,
            title: 'Optimize Sleep Schedule',
            description:
                'Long sleep may indicate poor quality. Try maintaining consistent bedtime and wake times.',
          ),
        );
      }
    }

    // Sleep quality suggestions
    if (sleepQuality < 5) {
      suggestions.add(
        SleepSuggestion(
          icon: Icons.bed,
          color: Colors.red,
          title: 'Improve Sleep Quality',
          description:
              'Consider evaluating your mattress, pillows, and bedroom environment for comfort.',
        ),
      );
    } else if (sleepQuality < 7) {
      suggestions.add(
        SleepSuggestion(
          icon: Icons.self_improvement,
          color: Colors.orange,
          title: 'Enhance Sleep Routine',
          description:
              'Try relaxation techniques like meditation or gentle stretching before bed.',
        ),
      );
    }

    // Interruption suggestions
    if (interruptions >= 4) {
      suggestions.add(
        SleepSuggestion(
          icon: Icons.volume_off,
          color: Colors.red,
          title: 'Reduce Sleep Interruptions',
          description:
              'High interruption count may indicate environmental issues or stress. Consider white noise or addressing underlying causes.',
        ),
      );
    } else if (interruptions >= 2) {
      suggestions.add(
        SleepSuggestion(
          icon: Icons.notifications_off,
          color: Colors.orange,
          title: 'Minimize Disruptions',
          description:
              'Turn off notifications and ensure your bedroom is conducive to uninterrupted sleep.',
        ),
      );
    }

    return suggestions;
  }

  List<String> _generateOptimalTimes() {
    final now = DateTime.now();
    final optimalBedtimes = [
      DateTime(now.year, now.month, now.day, 21, 30), // 9:30 PM
      DateTime(now.year, now.month, now.day, 22, 0), // 10:00 PM
      DateTime(now.year, now.month, now.day, 22, 30), // 10:30 PM
      DateTime(now.year, now.month, now.day, 23, 0), // 11:00 PM
    ];

    return optimalBedtimes.map((bedtime) {
      final wakeTime = bedtime.add(const Duration(hours: 8));
      return 'Bedtime: ${_formatTime(bedtime)} → Wake: ${_formatTime(wakeTime)} (8h sleep)';
    }).toList();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  List<String> _getGeneralSleepTips() {
    return [
      'Maintain consistent sleep and wake times, even on weekends',
      'Create a relaxing bedtime routine 30-60 minutes before sleep',
      'Keep your bedroom cool, dark, and quiet',
      'Avoid caffeine, large meals, and screens 2-3 hours before bed',
      'Get natural sunlight exposure during the day',
      'Use your bed only for sleep and intimacy',
      'If you can\'t fall asleep within 20 minutes, get up and do a quiet activity',
    ];
  }
}

class SleepSuggestion {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const SleepSuggestion({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
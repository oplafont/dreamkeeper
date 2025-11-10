import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SleepCorrelationWidget extends StatelessWidget {
  final double sleepQuality;
  final Duration? sleepDuration;

  const SleepCorrelationWidget({
    super.key,
    required this.sleepQuality,
    this.sleepDuration,
  });

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
          Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.accentPurple, size: 5.w),
              SizedBox(width: 2.w),
              Text(
                'Dream-Sleep Correlation',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.w),

          // Dream Vividness Prediction
          _buildCorrelationCard(
            title: 'Dream Vividness',
            prediction: _predictDreamVividness(),
            description: _getDreamVividnessDescription(),
            color: _getDreamVividnessColor(),
            icon: Icons.color_lens,
          ),

          SizedBox(height: 3.w),

          // Dream Recall Prediction
          _buildCorrelationCard(
            title: 'Dream Recall Quality',
            prediction: _predictDreamRecall(),
            description: _getDreamRecallDescription(),
            color: _getDreamRecallColor(),
            icon: Icons.psychology,
          ),

          SizedBox(height: 3.w),

          // REM Sleep Indicator
          _buildCorrelationCard(
            title: 'REM Sleep Quality',
            prediction: _predictREMQuality(),
            description: _getREMQualityDescription(),
            color: _getREMQualityColor(),
            icon: Icons.waves,
          ),

          SizedBox(height: 4.w),

          // Overall Insights
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDarkest,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: _getOverallColor().withAlpha(128),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights, color: _getOverallColor(), size: 4.w),
                    SizedBox(width: 2.w),
                    Text(
                      'Tonight\'s Dream Forecast',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.w),

                Text(
                  _getOverallInsight(),
                  style: TextStyle(
                    color: AppTheme.textLightGray,
                    fontSize: 11.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                SizedBox(height: 2.w),

                Text(
                  _getRecordingTip(),
                  style: TextStyle(
                    color: _getOverallColor(),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationCard({
    required String title,
    required String prediction,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkest,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: color.withAlpha(128), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Icon(icon, color: color, size: 5.w),
          ),

          SizedBox(width: 3.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 1.w),

                Text(
                  prediction,
                  style: TextStyle(
                    color: color,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 1.w),

                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),

          // Visual Indicator
          Container(
            width: 3.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(1.w),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: _getIndicatorHeight(title),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Prediction Methods
  String _predictDreamVividness() {
    if (sleepQuality >= 8) return 'High Vividness';
    if (sleepQuality >= 6) return 'Moderate Vividness';
    if (sleepQuality >= 4) return 'Low Vividness';
    return 'Minimal Dreams';
  }

  String _getDreamVividnessDescription() {
    if (sleepQuality >= 8) {
      return 'Excellent sleep quality often leads to rich, detailed dreams with vivid imagery.';
    } else if (sleepQuality >= 6) {
      return 'Good sleep supports moderate dream activity with clear visual elements.';
    } else if (sleepQuality >= 4) {
      return 'Fair sleep may result in fragmented or less detailed dream content.';
    }
    return 'Poor sleep quality typically reduces dream formation and recall.';
  }

  Color _getDreamVividnessColor() {
    if (sleepQuality >= 8) return Colors.purple;
    if (sleepQuality >= 6) return Colors.blue;
    if (sleepQuality >= 4) return Colors.orange;
    return Colors.red;
  }

  String _predictDreamRecall() {
    final recallScore = _calculateRecallScore();
    if (recallScore >= 8) return 'Excellent Recall';
    if (recallScore >= 6) return 'Good Recall';
    if (recallScore >= 4) return 'Fair Recall';
    return 'Poor Recall';
  }

  double _calculateRecallScore() {
    double score = sleepQuality;

    // Sleep duration affects recall
    if (sleepDuration != null) {
      final hours = sleepDuration!.inHours;
      if (hours >= 7 && hours <= 9) {
        score += 1; // Optimal duration boosts recall
      } else if (hours < 6 || hours > 10) {
        score -= 1; // Poor duration reduces recall
      }
    }

    return score.clamp(1.0, 10.0);
  }

  String _getDreamRecallDescription() {
    final score = _calculateRecallScore();
    if (score >= 8) {
      return 'Optimal conditions for remembering detailed dream sequences and emotions.';
    } else if (score >= 6) {
      return 'Good chance of recalling main dream themes and some specific details.';
    } else if (score >= 4) {
      return 'May remember fragments or general impression of dreaming.';
    }
    return 'Dream recall likely to be minimal or absent upon waking.';
  }

  Color _getDreamRecallColor() {
    final score = _calculateRecallScore();
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  String _predictREMQuality() {
    final remScore = _calculateREMScore();
    if (remScore >= 8) return 'Optimal REM';
    if (remScore >= 6) return 'Good REM';
    if (remScore >= 4) return 'Fair REM';
    return 'Poor REM';
  }

  double _calculateREMScore() {
    double score = sleepQuality;

    if (sleepDuration != null) {
      final hours = sleepDuration!.inHours;
      // REM peaks in later sleep cycles
      if (hours >= 7) {
        score += 1.5;
      } else if (hours >= 6) {
        score += 0.5;
      } else {
        score -= 2; // Insufficient time for full REM cycles
      }
    }

    return score.clamp(1.0, 10.0);
  }

  String _getREMQualityDescription() {
    final score = _calculateREMScore();
    if (score >= 8) {
      return 'Perfect conditions for deep REM sleep and complex dream narratives.';
    } else if (score >= 6) {
      return 'Good REM sleep likely with structured dream sequences.';
    } else if (score >= 4) {
      return 'Moderate REM activity with some dream content expected.';
    }
    return 'Limited REM sleep may reduce dream complexity and emotional processing.';
  }

  Color _getREMQualityColor() {
    final score = _calculateREMScore();
    if (score >= 8) return Colors.indigo;
    if (score >= 6) return Colors.blue;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  Color _getOverallColor() {
    final averageScore =
        (sleepQuality + _calculateRecallScore() + _calculateREMScore()) / 3;
    if (averageScore >= 7) return Colors.green;
    if (averageScore >= 5) return Colors.orange;
    return Colors.red;
  }

  String _getOverallInsight() {
    final vividnessScore = sleepQuality;
    final recallScore = _calculateRecallScore();

    if (vividnessScore >= 7 && recallScore >= 7) {
      return 'Tonight shows excellent potential for memorable, vivid dreams. Your sleep conditions are optimal for rich dream experiences and strong morning recall.';
    } else if (vividnessScore >= 5 && recallScore >= 5) {
      return 'Good conditions for moderate dream activity. You\'re likely to experience some memorable dreams with decent recall upon waking.';
    } else {
      return 'Current sleep patterns suggest limited dream activity or recall. Consider optimizing your sleep environment and routine for better dream experiences.';
    }
  }

  String _getRecordingTip() {
    final overallScore = (sleepQuality + _calculateRecallScore()) / 2;

    if (overallScore >= 7) {
      return '💡 Tip: Keep your dream journal ready! Tonight has high potential for memorable dreams.';
    } else if (overallScore >= 5) {
      return '💡 Tip: Set a gentle morning alarm and record any dream fragments immediately upon waking.';
    } else {
      return '💡 Tip: Even brief dream impressions are valuable. Note any emotions or colors you remember.';
    }
  }

  double _getIndicatorHeight(String title) {
    switch (title) {
      case 'Dream Vividness':
        return (sleepQuality / 10).clamp(0.1, 1.0);
      case 'Dream Recall Quality':
        return (_calculateRecallScore() / 10).clamp(0.1, 1.0);
      case 'REM Sleep Quality':
        return (_calculateREMScore() / 10).clamp(0.1, 1.0);
      default:
        return 0.5;
    }
  }
}
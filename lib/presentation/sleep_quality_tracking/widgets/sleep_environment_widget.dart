import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SleepEnvironmentWidget extends StatelessWidget {
  final String temperature;
  final String noiseLevel;
  final String lightExposure;
  final Function(String) onTemperatureChanged;
  final Function(String) onNoiseLevelChanged;
  final Function(String) onLightExposureChanged;

  const SleepEnvironmentWidget({
    super.key,
    required this.temperature,
    required this.noiseLevel,
    required this.lightExposure,
    required this.onTemperatureChanged,
    required this.onNoiseLevelChanged,
    required this.onLightExposureChanged,
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
          Text(
            'Sleep Environment',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 4.w),

          // Room Temperature
          _buildEnvironmentSection(
            title: 'Room Temperature',
            icon: Icons.thermostat,
            iconColor: Colors.orange,
            options: [
              EnvironmentOption(
                'too_cold',
                'Too Cold',
                Icons.ac_unit,
                Colors.blue,
              ),
              EnvironmentOption(
                'cool',
                'Cool',
                Icons.thermostat,
                Colors.lightBlue,
              ),
              EnvironmentOption(
                'comfortable',
                'Comfortable',
                Icons.thermostat,
                Colors.green,
              ),
              EnvironmentOption(
                'warm',
                'Warm',
                Icons.thermostat,
                Colors.orange,
              ),
              EnvironmentOption(
                'too_hot',
                'Too Hot',
                Icons.whatshot,
                Colors.red,
              ),
            ],
            selectedValue: temperature,
            onChanged: onTemperatureChanged,
          ),

          SizedBox(height: 4.w),

          // Noise Level
          _buildEnvironmentSection(
            title: 'Noise Level',
            icon: Icons.volume_up,
            iconColor: Colors.purple,
            options: [
              EnvironmentOption(
                'silent',
                'Silent',
                Icons.volume_off,
                Colors.green,
              ),
              EnvironmentOption(
                'quiet',
                'Quiet',
                Icons.volume_down,
                Colors.lightGreen,
              ),
              EnvironmentOption(
                'moderate',
                'Moderate',
                Icons.volume_up,
                Colors.orange,
              ),
              EnvironmentOption('loud', 'Loud', Icons.volume_up, Colors.red),
              EnvironmentOption(
                'very_loud',
                'Very Loud',
                Icons.campaign,
                Colors.red.shade700,
              ),
            ],
            selectedValue: noiseLevel,
            onChanged: onNoiseLevelChanged,
          ),

          SizedBox(height: 4.w),

          // Light Exposure
          _buildEnvironmentSection(
            title: 'Light Exposure',
            icon: Icons.wb_sunny,
            iconColor: Colors.yellow,
            options: [
              EnvironmentOption(
                'dark',
                'Dark',
                Icons.nightlight,
                Colors.indigo,
              ),
              EnvironmentOption('dim', 'Dim', Icons.wb_twilight, Colors.purple),
              EnvironmentOption(
                'moderate',
                'Moderate',
                Icons.wb_cloudy,
                Colors.orange,
              ),
              EnvironmentOption(
                'bright',
                'Bright',
                Icons.wb_sunny,
                Colors.yellow,
              ),
              EnvironmentOption(
                'very_bright',
                'Very Bright',
                Icons.flare,
                Colors.amber,
              ),
            ],
            selectedValue: lightExposure,
            onChanged: onLightExposureChanged,
          ),

          SizedBox(height: 4.w),

          // Environment Score
          _buildEnvironmentScore(),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<EnvironmentOption> options,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 5.w),
            SizedBox(width: 2.w),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        SizedBox(height: 2.w),

        Wrap(
          spacing: 2.w,
          runSpacing: 2.w,
          children:
              options.map((option) {
                final isSelected = selectedValue == option.value;
                return GestureDetector(
                  onTap: () => onChanged(option.value),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 2.w,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? option.color.withAlpha(51)
                              : AppTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color:
                            isSelected
                                ? option.color
                                : AppTheme.borderPurple.withAlpha(64),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          option.icon,
                          color:
                              isSelected
                                  ? option.color
                                  : AppTheme.textMediumGray,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          option.label,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? AppTheme.textWhite
                                    : AppTheme.textMediumGray,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildEnvironmentScore() {
    final score = _calculateEnvironmentScore();
    final scoreColor = _getScoreColor(score);
    final scoreLabel = _getScoreLabel(score);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkest,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: scoreColor.withAlpha(128), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getScoreIcon(score), color: scoreColor, size: 6.w),
              SizedBox(width: 2.w),
              Text(
                'Environment Score: $score/10',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.w),

          Text(
            scoreLabel,
            style: TextStyle(
              color: scoreColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.w),

          Text(
            _getEnvironmentAdvice(score),
            style: TextStyle(
              color: AppTheme.textLightGray,
              fontSize: 10.sp,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _calculateEnvironmentScore() {
    int score = 0;

    // Temperature scoring
    switch (temperature) {
      case 'comfortable':
        score += 4;
        break;
      case 'cool':
        score += 3;
        break;
      case 'warm':
        score += 2;
        break;
      case 'too_cold':
      case 'too_hot':
        score += 1;
        break;
    }

    // Noise scoring
    switch (noiseLevel) {
      case 'silent':
      case 'quiet':
        score += 3;
        break;
      case 'moderate':
        score += 2;
        break;
      case 'loud':
        score += 1;
        break;
      case 'very_loud':
        score += 0;
        break;
    }

    // Light scoring
    switch (lightExposure) {
      case 'dark':
        score += 3;
        break;
      case 'dim':
        score += 2;
        break;
      case 'moderate':
        score += 1;
        break;
      case 'bright':
      case 'very_bright':
        score += 0;
        break;
    }

    return score;
  }

  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.lightGreen;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 8) return 'Optimal Sleep Environment';
    if (score >= 6) return 'Good Sleep Environment';
    if (score >= 4) return 'Fair Sleep Environment';
    return 'Poor Sleep Environment';
  }

  IconData _getScoreIcon(int score) {
    if (score >= 8) return Icons.check_circle;
    if (score >= 6) return Icons.thumb_up;
    if (score >= 4) return Icons.warning;
    return Icons.error;
  }

  String _getEnvironmentAdvice(int score) {
    if (score >= 8) {
      return 'Perfect conditions for quality sleep! Keep it up.';
    } else if (score >= 6) {
      return 'Good environment with room for minor improvements.';
    } else if (score >= 4) {
      return 'Consider adjusting temperature, noise, or light levels.';
    } else {
      return 'Multiple factors may be affecting your sleep quality.';
    }
  }
}

class EnvironmentOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const EnvironmentOption(this.value, this.label, this.icon, this.color);
}
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SleepQualitySliderWidget extends StatelessWidget {
  final double quality;
  final Function(double) onChanged;

  const SleepQualitySliderWidget({
    super.key,
    required this.quality,
    required this.onChanged,
  });

  String _getQualityLabel(double value) {
    if (value <= 2) return 'Poor';
    if (value <= 4) return 'Fair';
    if (value <= 6) return 'Good';
    if (value <= 8) return 'Very Good';
    return 'Excellent';
  }

  Color _getQualityColor(double value) {
    if (value <= 2) return Colors.red;
    if (value <= 4) return Colors.orange;
    if (value <= 6) return Colors.yellow;
    if (value <= 8) return Colors.lightGreen;
    return Colors.green;
  }

  IconData _getQualityIcon(double value) {
    if (value <= 2) return Icons.sentiment_very_dissatisfied;
    if (value <= 4) return Icons.sentiment_dissatisfied;
    if (value <= 6) return Icons.sentiment_neutral;
    if (value <= 8) return Icons.sentiment_satisfied;
    return Icons.sentiment_very_satisfied;
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
            'Sleep Quality',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 4.w),

          // Quality Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getQualityIcon(quality),
                color: _getQualityColor(quality),
                size: 8.w,
              ),
              SizedBox(width: 3.w),
              Column(
                children: [
                  Text(
                    quality.toInt().toString(),
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getQualityLabel(quality),
                    style: TextStyle(
                      color: _getQualityColor(quality),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 4.w),

          // Quality Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getQualityColor(quality),
              inactiveTrackColor: AppTheme.borderPurple.withAlpha(64),
              thumbColor: _getQualityColor(quality),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 3.w),
              overlayColor: _getQualityColor(quality).withAlpha(64),
              trackHeight: 1.w,
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: _getQualityColor(quality),
              valueIndicatorTextStyle: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Slider(
              value: quality,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: quality.toInt().toString(),
              onChanged: onChanged,
            ),
          ),

          // Scale Labels
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1\nPoor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  '5\nAverage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  '10\nExcellent',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.w),

          // Quality Description
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDarkest,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: _getQualityColor(quality).withAlpha(128),
                width: 1,
              ),
            ),
            child: Text(
              _getQualityDescription(quality),
              style: TextStyle(
                color: AppTheme.textLightGray,
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getQualityDescription(double value) {
    if (value <= 2) {
      return 'Restless sleep with frequent awakenings. Felt tired upon waking.';
    } else if (value <= 4) {
      return 'Light sleep with some interruptions. Not fully refreshed in the morning.';
    } else if (value <= 6) {
      return 'Average sleep quality. Felt reasonably rested upon waking.';
    } else if (value <= 8) {
      return 'Good quality sleep with minimal interruptions. Woke up refreshed.';
    } else {
      return 'Deep, uninterrupted sleep. Felt completely refreshed and energized.';
    }
  }
}
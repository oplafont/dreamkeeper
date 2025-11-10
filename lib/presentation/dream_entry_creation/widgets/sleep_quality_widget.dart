import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SleepQualityWidget extends StatefulWidget {
  final double sleepQuality;
  final Function(double) onQualityChanged;

  const SleepQualityWidget({
    Key? key,
    required this.sleepQuality,
    required this.onQualityChanged,
  }) : super(key: key);

  @override
  State<SleepQualityWidget> createState() => _SleepQualityWidgetState();
}

class _SleepQualityWidgetState extends State<SleepQualityWidget> {
  String _getQualityLabel(double value) {
    if (value <= 2) return 'Very Poor';
    if (value <= 4) return 'Poor';
    if (value <= 6) return 'Fair';
    if (value <= 8) return 'Good';
    return 'Excellent';
  }

  Color _getQualityColor(double value) {
    if (value <= 2) return AppTheme.lightTheme.colorScheme.error;
    if (value <= 4) return const Color(0xFFFF9800);
    if (value <= 6) return const Color(0xFFFFC107);
    if (value <= 8) return const Color(0xFF4CAF50);
    return const Color(0xFF2E7D32);
  }

  String _getQualityEmoji(double value) {
    if (value <= 2) return '😴';
    if (value <= 4) return '😪';
    if (value <= 6) return '😐';
    if (value <= 8) return '😊';
    return '😁';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Quality',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rate your sleep quality (1-10)',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getQualityColor(
                          widget.sleepQuality,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getQualityColor(widget.sleepQuality),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getQualityEmoji(widget.sleepQuality),
                            style: TextStyle(fontSize: 4.w),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${widget.sleepQuality.toInt()}',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                                  color: _getQualityColor(widget.sleepQuality),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _getQualityColor(widget.sleepQuality),
                    inactiveTrackColor: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    thumbColor: _getQualityColor(widget.sleepQuality),
                    overlayColor: _getQualityColor(
                      widget.sleepQuality,
                    ).withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    trackHeight: 6,
                    valueIndicatorShape:
                        const PaddleSliderValueIndicatorShape(),
                    valueIndicatorColor: _getQualityColor(widget.sleepQuality),
                    valueIndicatorTextStyle: AppTheme
                        .lightTheme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  child: Slider(
                    value: widget.sleepQuality,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '${widget.sleepQuality.toInt()}',
                    onChanged: widget.onQualityChanged,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Very Poor',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Excellent',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getQualityColor(
                      widget.sleepQuality,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getQualityColor(
                        widget.sleepQuality,
                      ).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getQualityEmoji(widget.sleepQuality),
                        style: TextStyle(fontSize: 5.w),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _getQualityLabel(widget.sleepQuality),
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                              color: _getQualityColor(widget.sleepQuality),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/dream.dart';
import '../../../theme/app_theme.dart';

class ClarityScoreWidget extends StatefulWidget {
  final double clarityScore;
  final ValueChanged<double> onClarityChanged;

  const ClarityScoreWidget({
    Key? key,
    required this.clarityScore,
    required this.onClarityChanged,
  }) : super(key: key);

  @override
  State<ClarityScoreWidget> createState() => _ClarityScoreWidgetState();
}

class _ClarityScoreWidgetState extends State<ClarityScoreWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dream Clarity',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getClarityColor().withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getClarityLabel(),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _getClarityColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'How clear and vivid was this dream?',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: _getClarityColor(),
                    inactiveTrackColor: AppTheme.lightTheme.colorScheme.outline,
                    thumbColor: _getClarityColor(),
                    overlayColor: _getClarityColor().withAlpha(51),
                    trackHeight: 1.h,
                  ),
                  child: Slider(
                    value: widget.clarityScore,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    label: widget.clarityScore.toStringAsFixed(0),
                    onChanged: widget.onClarityChanged,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: _getClarityColor().withAlpha(51),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.clarityScore.toStringAsFixed(0),
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: _getClarityColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vague',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Crystal Clear',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getClarityColor() {
    if (widget.clarityScore >= 8) {
      return Colors.green;
    } else if (widget.clarityScore >= 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getClarityLabel() {
    if (widget.clarityScore >= 8) {
      return 'Very Clear';
    } else if (widget.clarityScore >= 5) {
      return 'Moderately Clear';
    } else {
      return 'Vague';
    }
  }
}

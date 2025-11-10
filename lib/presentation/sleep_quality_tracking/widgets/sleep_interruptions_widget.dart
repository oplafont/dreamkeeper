import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SleepInterruptionsWidget extends StatelessWidget {
  final int interruptions;
  final Function(int) onChanged;

  const SleepInterruptionsWidget({
    super.key,
    required this.interruptions,
    required this.onChanged,
  });

  String _getInterruptionLabel(int count) {
    if (count == 0) return 'No interruptions';
    if (count == 1) return '1 interruption';
    return '$count interruptions';
  }

  Color _getInterruptionColor(int count) {
    if (count == 0) return Colors.green;
    if (count <= 2) return Colors.yellow;
    if (count <= 4) return Colors.orange;
    return Colors.red;
  }

  IconData _getInterruptionIcon(int count) {
    if (count == 0) return Icons.check_circle;
    if (count <= 2) return Icons.warning;
    return Icons.error;
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
            'Sleep Interruptions',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 4.w),

          // Interruption Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getInterruptionIcon(interruptions),
                color: _getInterruptionColor(interruptions),
                size: 8.w,
              ),
              SizedBox(width: 3.w),
              Column(
                children: [
                  Text(
                    interruptions.toString(),
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getInterruptionLabel(interruptions),
                    style: TextStyle(
                      color: _getInterruptionColor(interruptions),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 4.w),

          // Counter Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrease Button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDarkPurple,
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(
                    color: AppTheme.borderPurple.withAlpha(128),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed:
                      interruptions > 0
                          ? () => onChanged(interruptions - 1)
                          : null,
                  icon: Icon(
                    Icons.remove,
                    color:
                        interruptions > 0
                            ? AppTheme.accentPurple
                            : AppTheme.textMediumGray,
                    size: 6.w,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Count Display
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
                decoration: BoxDecoration(
                  color: AppTheme.cardDarkPurple,
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(
                    color: _getInterruptionColor(interruptions).withAlpha(128),
                    width: 1,
                  ),
                ),
                child: Text(
                  interruptions.toString(),
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Increase Button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDarkPurple,
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(
                    color: AppTheme.borderPurple.withAlpha(128),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed:
                      interruptions < 20
                          ? () => onChanged(interruptions + 1)
                          : null,
                  icon: Icon(
                    Icons.add,
                    color:
                        interruptions < 20
                            ? AppTheme.accentPurple
                            : AppTheme.textMediumGray,
                    size: 6.w,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4.w),

          // Quick Selection Buttons
          Wrap(
            spacing: 2.w,
            runSpacing: 2.w,
            children:
                [0, 1, 2, 3, 5, 8].map((count) {
                  final isSelected = interruptions == count;
                  return GestureDetector(
                    onTap: () => onChanged(count),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.5.w,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppTheme.accentPurple
                                : AppTheme.cardDarkPurple,
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppTheme.accentPurple
                                  : AppTheme.borderPurple.withAlpha(64),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color:
                              isSelected
                                  ? AppTheme.textWhite
                                  : AppTheme.textMediumGray,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          SizedBox(height: 3.w),

          // Help Text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkPurple,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Common causes of sleep interruptions:',
                  style: TextStyle(
                    color: AppTheme.textLightGray,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  '• Bathroom visits • Noise disturbances • Temperature changes\n'
                  '• Dreams/nightmares • Stress/anxiety • Phone notifications',
                  style: TextStyle(
                    color: AppTheme.textMediumGray,
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
}
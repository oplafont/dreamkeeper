import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class InsightCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color? cardColor;
  final Widget? chart;
  final VoidCallback? onTap;

  const InsightCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.cardColor,
    this.chart,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: cardColor ?? AppTheme.cardDarkPurple,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderPurple.withAlpha(128),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                color: AppTheme.accentPurpleLight,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMediumGray,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (chart != null) ...[
              SizedBox(height: 2.h),
              SizedBox(height: 20.h, child: chart!),
            ],
          ],
        ),
      ),
    );
  }
}

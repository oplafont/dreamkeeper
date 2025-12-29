import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FeedDreamCardWidget extends StatelessWidget {
  final Map<String, dynamic> dream;
  final VoidCallback onTap;
  final VoidCallback onResonance;
  final VoidCallback onReport;

  const FeedDreamCardWidget({
    super.key,
    required this.dream,
    required this.onTap,
    required this.onResonance,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onResonance,
      onLongPress: onReport,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.wineRed.withAlpha(77), AppTheme.cardDarkBurgundy],
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppTheme.borderPurple.withAlpha(128),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.accentRedPurple,
                  radius: 16,
                  child: Text(
                    dream['username'][0],
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dream['username'],
                        style: TextStyle(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      Text(
                        dream['timestamp'],
                        style: TextStyle(
                          color: AppTheme.textDisabledGray,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (dream['isTrending'] == true)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.coralRed.withAlpha(51),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppTheme.coralRed, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppTheme.coralRed,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Trending',
                          style: TextStyle(
                            color: AppTheme.coralRed,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              dream['title'],
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Text(
              dream['snippet'],
              style: TextStyle(
                color: AppTheme.textLightGray,
                fontSize: 13.sp,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: (dream['symbols'] as List).take(3).map<Widget>((
                symbol,
              ) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.5.w,
                    vertical: 0.6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardMediumPurple,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: AppTheme.accentRedPurple.withAlpha(128),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$symbol',
                    style: TextStyle(
                      color: AppTheme.accentRedPurple,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: AppTheme.textMediumGray,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${dream['views']}',
                      style: TextStyle(
                        color: AppTheme.textMediumGray,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.favorite_outline,
                      color: AppTheme.coralRed,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${dream['resonance']}',
                      style: TextStyle(
                        color: AppTheme.textMediumGray,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.5.w,
                    vertical: 0.6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardMediumPurple,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_emotions_outlined,
                        color: AppTheme.softPink,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        dream['emotion'],
                        style: TextStyle(
                          color: AppTheme.textLightGray,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

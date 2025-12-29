import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TrendingSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> trendingDreams;
  final Function(Map<String, dynamic>) onDreamTap;

  const TrendingSectionWidget({
    super.key,
    required this.trendingDreams,
    required this.onDreamTap,
  });

  @override
  Widget build(BuildContext context) {
    if (trendingDreams.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 2.h, bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppTheme.coralRed,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Trending Dreams',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: trendingDreams.length,
              itemBuilder: (context, index) {
                final dream = trendingDreams[index];
                return _buildTrendingCard(dream);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(Map<String, dynamic> dream) {
    return GestureDetector(
      onTap: () => onDreamTap(dream),
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.coralRed.withAlpha(128),
              AppTheme.wineRed.withAlpha(179),
            ],
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppTheme.coralRed.withAlpha(128), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.coralRed.withAlpha(77),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.coralRed,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppTheme.textWhite,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Trending',
                        style: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Icon(Icons.favorite, color: AppTheme.softPink, size: 16),
                SizedBox(width: 1.w),
                Text(
                  '${dream['resonance']}',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              dream['title'],
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.textWhite.withAlpha(51),
                  radius: 12,
                  child: Text(
                    dream['username'][0],
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    dream['username'],
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class AIRecommendationsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  final Function(Map<String, dynamic>) onRecommendationTap;

  const AIRecommendationsWidget({
    super.key,
    required this.recommendations,
    required this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: AppTheme.coralRed, size: 20),
              SizedBox(width: 2.w),
              Text(
                'AI Recommendations',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return _buildRecommendationCard(context, recommendation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    Map<String, dynamic> recommendation,
  ) {
    return GestureDetector(
      onTap: () => onRecommendationTap(recommendation),
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 3.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.cardMediumPurple,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppTheme.borderPurple.withAlpha(77),
            width: 1,
          ),
          gradient: LinearGradient(
            colors: [AppTheme.cardMediumPurple, AppTheme.cardDarkBurgundy],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recommendation['title'] ?? 'Untitled Dream',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            Text(
              recommendation['content'] ?? '',
              style: TextStyle(color: AppTheme.textLightGray, fontSize: 12.sp),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (recommendation['ai_symbols'] != null)
              Wrap(
                spacing: 1.w,
                children: (recommendation['ai_symbols'] as List)
                    .take(3)
                    .map(
                      (symbol) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRedPurple.withAlpha(51),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          '#$symbol',
                          style: TextStyle(
                            color: AppTheme.coralRed,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/dream.dart';

class DreamCardWidget extends StatelessWidget {
  final Dream dream;
  final VoidCallback onTap;

  const DreamCardWidget({
    super.key,
    required this.dream,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade800.withAlpha(204),
              Colors.blue.shade900.withAlpha(204),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Dream type and lucid indicators
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dream.dreamTypeIcon,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      if (dream.isLucid) ...[
                        SizedBox(width: 1.w),
                        Text(
                          '🌟',
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),

                // Date and mood
                Row(
                  children: [
                    Text(
                      dream.formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withAlpha(204),
                          ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      dream.moodEmoji,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Title
            Text(
              dream.displayTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 1.h),

            // Content Preview
            Text(
              dream.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(230),
                    height: 1.4,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 2.h),

            // Tags and AI Analysis Indicators
            Row(
              children: [
                // User Tags
                if (dream.tags.isNotEmpty) ...[
                  Expanded(
                    child: Wrap(
                      spacing: 1.w,
                      runSpacing: 0.5.h,
                      children: dream.tags.take(3).map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                    ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // Indicators
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // AI Analysis indicator
                    if (dream.hasAIAnalysis)
                      Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(51),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.psychology,
                          size: 4.w,
                          color: Colors.green.shade300,
                        ),
                      ),

                    SizedBox(width: 2.w),

                    // Audio indicator
                    if (dream.hasAudio)
                      Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(51),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.mic,
                          size: 4.w,
                          color: Colors.blue.shade300,
                        ),
                      ),

                    SizedBox(width: 2.w),

                    // Clarity Score
                    if (dream.clarityScore != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.w),
                        decoration: BoxDecoration(
                          color: _getClarityColor(dream.clarityScore!)
                              .withAlpha(51),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 3.w,
                              color: _getClarityColor(dream.clarityScore!),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              dream.clarityScore.toString(),
                              style: TextStyle(
                                color: _getClarityColor(dream.clarityScore!),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getClarityColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DreamSummaryCardWidget extends StatelessWidget {
  final Map<String, dynamic> dreamEntry;
  final VoidCallback onTap;

  const DreamSummaryCardWidget({
    super.key,
    required this.dreamEntry,
    required this.onTap,
  });

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'peaceful':
        return AppTheme.getSuccessColor();
      case 'anxious':
      case 'fearful':
      case 'nightmare':
        return AppTheme.lightTheme.colorScheme.error;
      case 'confused':
      case 'strange':
      case 'mysterious':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'sad':
      case 'melancholy':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = dreamEntry['title'] as String? ?? 'Untitled Dream';
    final String mood = dreamEntry['mood'] as String? ?? 'neutral';
    final String summary = dreamEntry['summary'] as String? ?? '';
    final String time = dreamEntry['time'] as String? ?? '';
    final double intensity =
        (dreamEntry['intensity'] as num?)?.toDouble() ?? 0.5;
    final List<String> tags =
        (dreamEntry['tags'] as List?)?.cast<String>() ?? [];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getMoodColor(mood).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow.withValues(
                alpha: 0.1,
              ),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getMoodColor(mood),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            if (summary.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Text(
                summary,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 1.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getMoodColor(mood).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'mood',
                        color: _getMoodColor(mood),
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        mood.toUpperCase(),
                        style: AppTheme.lightTheme.textTheme.labelSmall
                            ?.copyWith(
                              color: _getMoodColor(mood),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${(intensity * 10).toInt()}/10',
                        style: AppTheme.lightTheme.textTheme.labelSmall
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
            if (tags.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Wrap(
                spacing: 1.w,
                runSpacing: 0.5.h,
                children:
                    tags
                        .take(3)
                        .map(
                          (tag) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$tag',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                    color:
                                        AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
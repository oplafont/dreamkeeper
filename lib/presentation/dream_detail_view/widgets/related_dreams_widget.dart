import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RelatedDreamsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> relatedDreams;
  final Function(Map<String, dynamic>) onDreamTap;

  const RelatedDreamsWidget({
    Key? key,
    required this.relatedDreams,
    required this.onDreamTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (relatedDreams.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Related Dreams',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedDreams.length,
              itemBuilder: (context, index) {
                final dream = relatedDreams[index];
                return _buildRelatedDreamCard(dream, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedDreamCard(
    Map<String, dynamic> dream,
    BuildContext context,
  ) {
    final title = dream['title'] as String? ?? 'Untitled Dream';
    final description = dream['description'] as String? ?? '';
    final date = dream['creationDate'] as DateTime? ?? DateTime.now();
    final tags = (dream['tags'] as List?)?.cast<String>() ?? [];
    final mood = dream['mood'] as String? ?? 'Unknown';

    return GestureDetector(
      onTap: () => onDreamTap(dream),
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.3,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getMoodColor(mood).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    mood,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: _getMoodColor(mood),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: Text(
                description,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (tags.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${tags.length}',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'excited':
        return AppTheme.getSuccessColor();
      case 'sad':
      case 'melancholy':
      case 'depressed':
        return Colors.blue;
      case 'anxious':
      case 'fearful':
      case 'nightmare':
        return AppTheme.getWarningColor();
      case 'angry':
      case 'frustrated':
        return Colors.red;
      case 'peaceful':
      case 'calm':
      case 'serene':
        return AppTheme.getAccentPurpleLight();
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
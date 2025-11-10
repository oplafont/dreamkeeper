import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DreamMetadataWidget extends StatelessWidget {
  final Map<String, dynamic> dreamData;
  final VoidCallback? onEditTags;

  const DreamMetadataWidget({
    Key? key,
    required this.dreamData,
    this.onEditTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creationDate =
        dreamData['creationDate'] as DateTime? ?? DateTime.now();
    final sleepQuality = dreamData['sleepQuality'] as double? ?? 0.0;
    final mood = dreamData['mood'] as String? ?? 'Unknown';
    final tags = (dreamData['tags'] as List?)?.cast<String>() ?? [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dream Details',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildMetadataRow(
            'Date',
            '${creationDate.day}/${creationDate.month}/${creationDate.year}',
            CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(height: 2.h),
          _buildMetadataRow(
            'Sleep Quality',
            '${sleepQuality.toStringAsFixed(1)}/5.0',
            CustomIconWidget(
              iconName: 'bedtime',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 20,
            ),
          ),
          SizedBox(height: 2.h),
          _buildMetadataRow(
            'Mood',
            mood,
            CustomIconWidget(
              iconName: 'mood',
              color: AppTheme.getAccentPurpleLight(),
              size: 20,
            ),
          ),
          if (tags.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              'Tags',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: tags.map((tag) => _buildTagChip(tag, context)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, Widget icon) {
    return Row(
      children: [
        icon,
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag, BuildContext context) {
    return GestureDetector(
      onLongPress: onEditTags,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.secondaryContainer.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.secondary.withValues(
              alpha: 0.5,
            ),
            width: 1,
          ),
        ),
        child: Text(
          tag,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
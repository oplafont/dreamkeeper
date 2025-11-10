import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PatternInsightsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> insights;

  const PatternInsightsWidget({Key? key, required this.insights})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'psychology',
                color: AppTheme.accentPurple,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Pattern Insights',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ...insights.map((insight) => _buildInsightItem(insight)).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightItem(Map<String, dynamic> insight) {
    final type = insight['type'] as String? ?? 'general';
    final title = insight['title'] as String? ?? 'Insight';
    final description = insight['description'] as String? ?? '';
    final frequency = insight['frequency'] as int? ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getInsightTypeColor(type).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getInsightTypeLabel(type),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getInsightTypeColor(type),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (frequency > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${frequency}x',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            description,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getInsightTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'recurring':
        return 'Recurring Element';
      case 'theme':
        return 'Common Theme';
      case 'symbol':
        return 'Symbol Pattern';
      case 'emotion':
        return 'Emotional Pattern';
      case 'character':
        return 'Character Pattern';
      case 'location':
        return 'Location Pattern';
      default:
        return 'General Insight';
    }
  }

  Color _getInsightTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'recurring':
        return Colors.orange;
      case 'theme':
        return AppTheme.accentPurple;
      case 'symbol':
        return Colors.teal;
      case 'emotion':
        return Colors.pink;
      case 'character':
        return Colors.indigo;
      case 'location':
        return Colors.green;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
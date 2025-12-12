import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HelpSectionWidget extends StatelessWidget {
  const HelpSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'help',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Help & Support',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildHelpTile(
            context,
            'Frequently Asked Questions',
            'Find answers to common questions',
            'quiz',
            _openFAQ,
          ),
          SizedBox(height: 1.h),
          _buildHelpTile(
            context,
            'Contact Support',
            'Get help from our support team',
            'support_agent',
            _contactSupport,
          ),
          SizedBox(height: 1.h),
          _buildHelpTile(
            context,
            'App Tutorial',
            'Learn how to use DreamDecoder',
            'school',
            _startTutorial,
          ),
          SizedBox(height: 1.h),
          _buildHelpTile(
            context,
            'Dream Interpretation Guide',
            'Understanding your dreams better',
            'psychology',
            _openInterpretationGuide,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTile(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0.5.h),
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.secondary.withValues(
            alpha: 0.1,
          ),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 5.w,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 5.w,
      ),
      onTap: onTap,
    );
  }

  void _openFAQ() {
    // In a real app, this would navigate to FAQ screen or open web view
    print('Opening FAQ');
  }

  void _contactSupport() {
    // In a real app, this would open email client or support chat
    print('Contacting support');
  }

  void _startTutorial() {
    // In a real app, this would start the app tutorial
    print('Starting tutorial');
  }

  void _openInterpretationGuide() {
    // In a real app, this would open dream interpretation resources
    print('Opening interpretation guide');
  }
}

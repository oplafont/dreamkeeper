import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class NotificationPreviewWidget extends StatefulWidget {
  final String notificationType;
  final Map<String, dynamic> settings;

  const NotificationPreviewWidget({
    super.key,
    required this.notificationType,
    required this.settings,
  });

  @override
  State<NotificationPreviewWidget> createState() =>
      _NotificationPreviewWidgetState();
}

class _NotificationPreviewWidgetState extends State<NotificationPreviewWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDarkPurple,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: AppTheme.accentPurpleLight,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Notification Preview',
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: _showPreview,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: AppTheme.accentPurpleLight,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Test',
                        style: TextStyle(color: AppTheme.accentPurpleLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Preview Content
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildNotificationPreview(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPreview() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDarkest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderPurple.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(),
                  color: AppTheme.textWhite,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'DreamKeeper',
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Text(
                          _getNotificationTime(),
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMediumGray,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getNotificationTitle(),
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Notification Body
          Text(
            _getNotificationBody(),
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLightGray,
              height: 1.4,
            ),
          ),

          // Action Buttons (for some notification types)
          if (_hasActionButtons()) ...[
            SizedBox(height: 2.h),
            Row(
              children: _getActionButtons(),
            ),
          ],

          // Additional Info
          if (_getAdditionalInfo().isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.accentPurpleLight,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _getAdditionalInfo(),
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLightGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (widget.notificationType) {
      case 'morning':
        return Icons.wb_sunny;
      case 'bedtime':
        return Icons.nights_stay;
      case 'weekly':
        return Icons.analytics;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationTime() {
    switch (widget.notificationType) {
      case 'morning':
        return widget.settings['reminderTime'] ?? '7:30 AM';
      case 'bedtime':
        final bedtime = widget.settings['optimalBedtime'] ?? '22:30';
        final leadTime = widget.settings['leadTime'] ?? 30;
        // Calculate reminder time based on bedtime and lead time
        final parts = bedtime.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final reminderMinutes = (hour * 60 + minute) - leadTime;
        final reminderHour = reminderMinutes ~/ 60;
        final reminderMinute = reminderMinutes % 60;
        return '${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}';
      case 'weekly':
        final day = widget.settings['deliveryDay'] ?? 'sunday';
        final time = widget.settings['deliveryTime'] ?? '19:00';
        return '$day, $time';
      default:
        return 'now';
    }
  }

  String _getNotificationTitle() {
    switch (widget.notificationType) {
      case 'morning':
        if (widget.settings['smartWakeDetection'] == true) {
          return '🌅 Dream Capture - Perfect Timing!';
        }
        return '🌅 Time to Capture Your Dreams';
      case 'bedtime':
        if (widget.settings['windDownReminder'] == true) {
          return '🌙 Wind-Down Time';
        }
        return '🌙 Bedtime Reminder';
      case 'weekly':
        return '📊 Your Weekly Dream Insights';
      default:
        return 'DreamKeeper Notification';
    }
  }

  String _getNotificationBody() {
    switch (widget.notificationType) {
      case 'morning':
        if (widget.settings['smartWakeDetection'] == true) {
          return 'Perfect timing! You\'re in a light sleep phase. Take a moment to capture any dreams you remember before they fade away. 💭✨';
        }
        return 'Good morning! Did you have any dreams last night? Capture them now while they\'re still fresh in your memory. 🌅';
      case 'bedtime':
        if (widget.settings['sleepHygieneTips'] == true) {
          return 'Time to start your bedtime routine! 🌙\n\nTonight\'s tip: Keep your bedroom cool and dark for better dream recall. Sweet dreams await! 💤';
        }
        return 'It\'s time to start winding down for bed. Prepare your mind for a night of vivid dreams. Sweet dreams! 🌙';
      case 'weekly':
        final contentDepth = widget.settings['contentDepth'] ?? 'detailed';
        if (contentDepth == 'comprehensive') {
          return '🌟 Amazing week of dreaming!\n\n📊 7 dreams recorded • 85% accuracy\n🎭 Top themes: Flying, Water, Adventure\n💫 Mood: 70% positive dreams\n🧠 AI Insight: Your creativity is soaring!\n\n📖 Full report available in app';
        } else if (contentDepth == 'detailed') {
          return '🌙 Your dream journey this week:\n\n📈 5 dreams logged\n🎨 Recurring themes: Colors, Music\n💭 Notable: Increased lucidity\n\n✨ Tap to explore patterns';
        }
        return '🌟 Weekly Update: 4 dreams captured this week! Your recall is improving. Tap to see insights.';
      default:
        return 'DreamKeeper has something for you.';
    }
  }

  bool _hasActionButtons() {
    return widget.notificationType == 'morning' ||
        widget.notificationType == 'weekly';
  }

  List<Widget> _getActionButtons() {
    switch (widget.notificationType) {
      case 'morning':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.textMediumGray),
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text(
                'No Dreams',
                style: TextStyle(color: AppTheme.textMediumGray, fontSize: 3.w),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text(
                'Record Dream',
                style: TextStyle(fontSize: 3.w),
              ),
            ),
          ),
        ];
      case 'weekly':
        return [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.accentPurpleLight),
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text(
                'View Insights',
                style:
                    TextStyle(color: AppTheme.accentPurpleLight, fontSize: 3.w),
              ),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  String _getAdditionalInfo() {
    switch (widget.notificationType) {
      case 'morning':
        if (widget.settings['smartWakeDetection'] == true) {
          return 'Smart wake detection analyzed your sleep patterns and chose this optimal moment.';
        }
        return '';
      case 'bedtime':
        if (widget.settings['windDownReminder'] == true) {
          final leadTime = widget.settings['leadTime'] ?? 30;
          return 'Starting your routine ${leadTime} minutes early helps improve dream recall.';
        }
        return '';
      case 'weekly':
        if (widget.settings['includeInsights'] == true) {
          return 'AI-powered analysis included based on your preferences.';
        }
        return '';
      default:
        return '';
    }
  }

  void _showPreview() {
    _animationController.forward().then((_) {
      // Show actual system notification preview
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.notification_add,
                color: AppTheme.textWhite,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Preview notification sent! Check your notification panel.',
                  style: TextStyle(color: AppTheme.textWhite),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.accentPurple,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: Duration(seconds: 3),
        ),
      );

      // Reset animation after delay
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          _animationController.reverse();
        }
      });
    });
  }
}

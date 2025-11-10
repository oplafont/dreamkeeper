import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/advanced_settings_widget.dart';
import './widgets/bedtime_ritual_widget.dart';
import './widgets/morning_dream_capture_widget.dart';
import './widgets/notification_preview_widget.dart';
import './widgets/quick_setup_wizard_widget.dart';
import './widgets/smart_timing_algorithms_widget.dart';
import './widgets/weekly_pattern_summary_widget.dart';

class SmartNotificationsManagement extends StatefulWidget {
  const SmartNotificationsManagement({super.key});

  @override
  State<SmartNotificationsManagement> createState() =>
      _SmartNotificationsManagementState();
}

class _SmartNotificationsManagementState
    extends State<SmartNotificationsManagement> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Morning Dream Capture Settings
  Map<String, dynamic> _morningSettings = {
    'enabled': true,
    'reminderTime': '07:30',
    'smartWakeDetection': true,
    'snoozeDuration': 15,
    'gentleTone': 'soft_chime',
    'weekdaysOnly': false,
  };

  // Bedtime Ritual Settings
  Map<String, dynamic> _bedtimeSettings = {
    'enabled': true,
    'windDownReminder': true,
    'leadTime': 30,
    'sleepHygieneTips': true,
    'optimalBedtime': '22:30',
    'weekendDifferent': false,
  };

  // Weekly Pattern Summary Settings
  Map<String, dynamic> _weeklySettings = {
    'enabled': true,
    'frequency': 'weekly',
    'deliveryDay': 'sunday',
    'deliveryTime': '19:00',
    'contentDepth': 'detailed',
    'includeInsights': true,
  };

  // Smart Timing Settings
  Map<String, dynamic> _smartTimingSettings = {
    'enabled': true,
    'behaviorAnalysis': true,
    'meetingAvoidance': true,
    'sleepAvoidance': true,
    'locationBased': false,
    'dndRespect': true,
  };

  // Advanced Settings
  Map<String, dynamic> _advancedSettings = {
    'locationAdjustments': false,
    'seasonalTiming': false,
    'travelMode': false,
    'accessibilityMode': false,
    'debugMode': false,
  };

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotificationSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading from shared preferences or API
    await Future.delayed(Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save to local storage or API
      await Future.delayed(Duration(milliseconds: 1000));

      setState(() {
        _hasUnsavedChanges = false;
        _isLoading = false;
      });

      _showSnackBar('Notification settings saved successfully', isError: false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Failed to save settings. Please try again.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          return await _showUnsavedChangesDialog() ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDarkest,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryDarkPurple,
          elevation: 0,
          title: Text(
            'Smart Notifications',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textWhite,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textWhite),
            onPressed: () => _handleBackPress(),
          ),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: Icon(Icons.save, color: AppTheme.accentPurpleLight),
                onPressed: _isLoading ? null : _saveNotificationSettings,
              ),
            IconButton(
              icon: Icon(Icons.help_outline, color: AppTheme.textWhite),
              onPressed: _showHelpDialog,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.accentPurpleLight,
            labelColor: AppTheme.accentPurpleLight,
            unselectedLabelColor: AppTheme.textMediumGray,
            isScrollable: true,
            tabs: [
              Tab(text: 'Morning'),
              Tab(text: 'Bedtime'),
              Tab(text: 'Weekly'),
              Tab(text: 'Smart'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppTheme.accentPurple),
              )
            : Column(
                children: [
                  // Quick Setup Banner
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(4.w),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDarkPurple,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentPurpleLight.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppTheme.accentPurpleLight,
                          size: 6.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Setup Wizard',
                                style: AppTheme.darkTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: AppTheme.textWhite,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Let us optimize your notifications based on your sleep schedule',
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textLightGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _showQuickSetupWizard,
                          child: Text(
                            'Start',
                            style: TextStyle(color: AppTheme.accentPurpleLight),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab View Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Morning Dream Capture Tab
                        SingleChildScrollView(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            children: [
                              MorningDreamCaptureWidget(
                                settings: _morningSettings,
                                onSettingsChanged: _updateMorningSettings,
                              ),
                              SizedBox(height: 2.h),
                              NotificationPreviewWidget(
                                notificationType: 'morning',
                                settings: _morningSettings,
                              ),
                            ],
                          ),
                        ),

                        // Bedtime Ritual Tab
                        SingleChildScrollView(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            children: [
                              BedtimeRitualWidget(
                                settings: _bedtimeSettings,
                                onSettingsChanged: _updateBedtimeSettings,
                              ),
                              SizedBox(height: 2.h),
                              NotificationPreviewWidget(
                                notificationType: 'bedtime',
                                settings: _bedtimeSettings,
                              ),
                            ],
                          ),
                        ),

                        // Weekly Summary Tab
                        SingleChildScrollView(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            children: [
                              WeeklyPatternSummaryWidget(
                                settings: _weeklySettings,
                                onSettingsChanged: _updateWeeklySettings,
                              ),
                              SizedBox(height: 2.h),
                              NotificationPreviewWidget(
                                notificationType: 'weekly',
                                settings: _weeklySettings,
                              ),
                            ],
                          ),
                        ),

                        // Smart Timing Tab
                        SingleChildScrollView(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            children: [
                              SmartTimingAlgorithmsWidget(
                                settings: _smartTimingSettings,
                                onSettingsChanged: _updateSmartTimingSettings,
                              ),
                              SizedBox(height: 2.h),
                              AdvancedSettingsWidget(
                                settings: _advancedSettings,
                                onSettingsChanged: _updateAdvancedSettings,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Bar
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDarkPurple,
                      border: Border(
                        top: BorderSide(
                          color: AppTheme.borderPurple.withAlpha(77),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetToDefaults,
                            child: Text('Reset to Defaults'),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _saveNotificationSettings,
                            child: _isLoading
                                ? SizedBox(
                                    height: 4.w,
                                    width: 4.w,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.textWhite,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('Save Settings'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _updateMorningSettings(Map<String, dynamic> newSettings) {
    setState(() {
      _morningSettings = {..._morningSettings, ...newSettings};
      _hasUnsavedChanges = true;
    });
  }

  void _updateBedtimeSettings(Map<String, dynamic> newSettings) {
    setState(() {
      _bedtimeSettings = {..._bedtimeSettings, ...newSettings};
      _hasUnsavedChanges = true;
    });
  }

  void _updateWeeklySettings(Map<String, dynamic> newSettings) {
    setState(() {
      _weeklySettings = {..._weeklySettings, ...newSettings};
      _hasUnsavedChanges = true;
    });
  }

  void _updateSmartTimingSettings(Map<String, dynamic> newSettings) {
    setState(() {
      _smartTimingSettings = {..._smartTimingSettings, ...newSettings};
      _hasUnsavedChanges = true;
    });
  }

  void _updateAdvancedSettings(Map<String, dynamic> newSettings) {
    setState(() {
      _advancedSettings = {..._advancedSettings, ...newSettings};
      _hasUnsavedChanges = true;
    });
  }

  void _handleBackPress() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog().then((shouldPop) {
        if (shouldPop == true) {
          Navigator.of(context).pop();
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Unsaved Changes',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        content: Text(
          'You have unsaved changes. Do you want to discard them?',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLightGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMediumGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Discard',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              _saveNotificationSettings();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset to Defaults',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        content: Text(
          'This will reset all notification settings to their default values. This action cannot be undone.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLightGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMediumGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _performReset() {
    setState(() {
      _morningSettings = {
        'enabled': true,
        'reminderTime': '07:30',
        'smartWakeDetection': true,
        'snoozeDuration': 15,
        'gentleTone': 'soft_chime',
        'weekdaysOnly': false,
      };
      _bedtimeSettings = {
        'enabled': true,
        'windDownReminder': true,
        'leadTime': 30,
        'sleepHygieneTips': true,
        'optimalBedtime': '22:30',
        'weekendDifferent': false,
      };
      _weeklySettings = {
        'enabled': true,
        'frequency': 'weekly',
        'deliveryDay': 'sunday',
        'deliveryTime': '19:00',
        'contentDepth': 'detailed',
        'includeInsights': true,
      };
      _smartTimingSettings = {
        'enabled': true,
        'behaviorAnalysis': true,
        'meetingAvoidance': true,
        'sleepAvoidance': true,
        'locationBased': false,
        'dndRespect': true,
      };
      _advancedSettings = {
        'locationAdjustments': false,
        'seasonalTiming': false,
        'travelMode': false,
        'accessibilityMode': false,
        'debugMode': false,
      };
      _hasUnsavedChanges = true;
    });

    _showSnackBar('Settings reset to defaults', isError: false);
  }

  void _showQuickSetupWizard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickSetupWizardWidget(
        onCompleted: (settings) {
          setState(() {
            _morningSettings = {..._morningSettings, ...(settings['morning'] ?? {})};
            _bedtimeSettings = {..._bedtimeSettings, ...(settings['bedtime'] ?? {})};
            _weeklySettings = {..._weeklySettings, ...(settings['weekly'] ?? {})};
            _hasUnsavedChanges = true;
          });
        },
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: AppTheme.accentPurpleLight,
            ),
            SizedBox(width: 2.w),
            Text(
              'Smart Notifications Help',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                'Morning Capture',
                'Gentle reminders to record your dreams when you wake up. Smart wake detection avoids interrupting deep sleep.',
              ),
              SizedBox(height: 2.h),
              _buildHelpSection(
                'Bedtime Ritual',
                'Wind-down reminders and sleep hygiene tips to improve your dream recall and sleep quality.',
              ),
              SizedBox(height: 2.h),
              _buildHelpSection(
                'Weekly Summary',
                'Personalized insights and pattern analysis delivered on your preferred schedule.',
              ),
              SizedBox(height: 2.h),
              _buildHelpSection(
                'Smart Timing',
                'AI-powered algorithms that learn your behavior to deliver notifications at optimal times.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: TextStyle(color: AppTheme.accentPurpleLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.accentPurpleLight,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          description,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLightGray,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? AppTheme.errorColor : AppTheme.successColor,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.cardDarkPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }
}
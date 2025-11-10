import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/account_section_widget.dart';
import './widgets/app_preferences_widget.dart';
import './widgets/data_management_widget.dart';
import './widgets/help_section_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/privacy_controls_widget.dart';
import './widgets/profile_section_widget.dart';

class SettingsAndProfile extends StatefulWidget {
  const SettingsAndProfile({super.key});

  @override
  State<SettingsAndProfile> createState() => _SettingsAndProfileState();
}

class _SettingsAndProfileState extends State<SettingsAndProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic> _userProfile = {
    'name': 'Dream Explorer',
    'avatar': '',
    'avatarSemanticLabel': 'User Avatar',
    'memberSince': 'Jan 2025',
    'totalDreams': 42,
    'currentStreak': 7,
  };
  Map<String, dynamic> _preferences = {
    'darkTheme': true,
    'textSize': 1.0,
    'voiceQuality': 'medium',
  };
  Map<String, dynamic> _notificationSettings = {
    'streakNotifications': false,
    'reminderTime': '22:00',
    'insightFrequency': 'weekly',
  };
  Map<String, dynamic> _privacySettings = {
    'biometricAuth': false,
    'autoLockTimeout': '5min',
    'sharingPreference': 'private',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: 5);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDarkest,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDarkPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings & Profile',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppTheme.textWhite),
            onPressed: () {
              // Show help dialog
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.accentPurple),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 2));
                setState(() {
                  _isLoading = false;
                });
              },
              color: AppTheme.accentPurple,
              backgroundColor: AppTheme.cardDarkPurple,
              child: CustomScrollView(
                slivers: [
                  // Profile Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: ProfileSectionWidget(
                        userProfile: _userProfile,
                        onEditProfile: _editProfile,
                      ),
                    ),
                  ),

                  // Account Section
                  SliverToBoxAdapter(
                    child: AccountSectionWidget(
                      accountInfo: _userProfile,
                      onDeleteAccount: _deleteAccount,
                    ),
                  ),

                  // App Preferences
                  SliverToBoxAdapter(
                    child: AppPreferencesWidget(
                      appSettings: _preferences,
                      onSettingsChanged: (settings) {
                        setState(() {
                          _preferences = settings;
                        });
                      },
                    ),
                  ),

                  // Notification Settings
                  SliverToBoxAdapter(
                    child: NotificationSettingsWidget(
                      notificationSettings: _notificationSettings,
                      onSettingsChanged: (settings) {
                        setState(() {
                          _notificationSettings = settings;
                        });
                      },
                    ),
                  ),

                  // Privacy Controls
                  SliverToBoxAdapter(
                    child: PrivacyControlsWidget(
                      privacySettings: _privacySettings,
                      onSettingsChanged: (settings) {
                        setState(() {
                          _privacySettings = settings;
                        });
                      },
                    ),
                  ),

                  // Data Management
                  SliverToBoxAdapter(
                    child: DataManagementWidget(
                      dataSettings: _privacySettings,
                      onSettingsChanged: (settings) {
                        setState(() {
                          _privacySettings = settings;
                        });
                      },
                    ),
                  ),

                  // Help Section
                  SliverToBoxAdapter(
                    child: HelpSectionWidget(),
                  ),

                  // Logout Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Card(
                        color: AppTheme.cardDarkPurple,
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Account Actions',
                                style: AppTheme.darkTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: AppTheme.textWhite,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              ElevatedButton.icon(
                                onPressed: _signOut,
                                icon: Icon(Icons.logout,
                                    color: AppTheme.textWhite),
                                label: Text(
                                  'Sign Out',
                                  style: TextStyle(color: AppTheme.textWhite),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.errorColor,
                                  foregroundColor: AppTheme.textWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom padding for bottom navigation bar
                  SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                ],
              ),
            ),
    );
  }

  void _showHelpDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'DreamKeeper',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.nights_stay,
        color: AppTheme.accentPurpleLight,
        size: 48,
      ),
      children: [
        Text(
          'Your personal dream journaling companion. Track, analyze, and understand your dreams with AI-powered insights.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLightGray,
          ),
        ),
      ],
    );
  }

  void _editProfile() {
    _showEditProfileDialog();
  }

  void _updateAvatar(String avatarUrl) {
    setState(() {
      _userProfile['avatar'] = avatarUrl;
    });
  }

  void _changePassword() {
    _showChangePasswordDialog();
  }

  void _deleteAccount() {
    _showDeleteAccountDialog();
  }

  void _updatePreference(String key, dynamic value) {
    setState(() {
      _preferences[key] = value;
    });
  }

  void _updateNotificationSetting(String key, dynamic value) {
    setState(() {
      _notificationSettings[key] = value;
    });
  }

  void _updatePrivacySetting(String key, dynamic value) {
    setState(() {
      _privacySettings[key] = value;
    });
  }

  void _exportData() {
    _showSnackBar('Export data feature coming soon');
  }

  void _importData() {
    _showSnackBar('Import data feature coming soon');
  }

  void _clearCache() {
    _showSnackBar('Clear cache feature coming soon');
  }

  void _contactSupport() {
    _showSnackBar('Contact support feature coming soon');
  }

  void _viewFAQ() {
    _showSnackBar('FAQ view feature coming soon');
  }

  void _viewTermsAndConditions() {
    _showSnackBar('Terms and conditions view feature coming soon');
  }

  void _viewPrivacyPolicy() {
    _showSnackBar('Privacy policy view feature coming soon');
  }

  void _signOut() {
    _showSnackBar('Sign out feature coming soon');
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Profile',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLightGray,
              ),
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Dream Explorer',
                labelStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumGray,
                ),
                hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDisabledGray,
                ),
                fillColor: AppTheme.cardMediumPurple,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.borderPurple),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.borderPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.accentPurpleLight, width: 2),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: () {
                _showSnackBar('Photo selection feature coming soon!');
              },
              icon: Icon(
                Icons.photo_camera,
                color: AppTheme.textWhite,
                size: 4.w,
              ),
              label: Text('Change Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: AppTheme.textWhite,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textMediumGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar('Profile updated successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: AppTheme.textWhite,
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _showSnackBar('Change password feature coming soon');
  }

  void _showManageSubscriptionDialog() {
    _showSnackBar('Subscription management coming soon');
  }

  void _showBackupRestoreDialog() {
    _showSnackBar('Backup & restore feature coming soon');
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Account',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.errorColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLightGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textMediumGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar(
                  'Account deletion initiated. You will receive a confirmation email.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.textWhite,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDreamsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete All Dreams',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.errorColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all your dreams? This action cannot be undone.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLightGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textMediumGray,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSnackBar('All dreams deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.textWhite,
            ),
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'DreamKeeper',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.nights_stay,
        color: AppTheme.accentPurpleLight,
        size: 48,
      ),
      children: [
        Text(
          'Your personal dream journaling companion. Track, analyze, and understand your dreams with AI-powered insights.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLightGray,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        backgroundColor: AppTheme.accentPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
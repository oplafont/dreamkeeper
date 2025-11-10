import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PrivacyControlsWidget extends StatefulWidget {
  final Map<String, dynamic> privacySettings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const PrivacyControlsWidget({
    super.key,
    required this.privacySettings,
    required this.onSettingsChanged,
  });

  @override
  State<PrivacyControlsWidget> createState() => _PrivacyControlsWidgetState();
}

class _PrivacyControlsWidgetState extends State<PrivacyControlsWidget> {
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    _settings = Map<String, dynamic>.from(widget.privacySettings);
  }

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
                iconName: 'security',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Privacy & Security',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSwitchTile(
            'Biometric Authentication',
            'Use fingerprint or face recognition to unlock',
            'biometricAuth',
            'fingerprint',
          ),
          SizedBox(height: 2.h),
          _buildAutoLockSelector(),
          SizedBox(height: 2.h),
          _buildSharingPreferences(),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    String key,
    String iconName,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Switch(
            value: _settings[key] as bool,
            onChanged: (value) {
              setState(() {
                _settings[key] = value;
              });
              widget.onSettingsChanged(_settings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAutoLockSelector() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lock_clock',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Auto-Lock Timeout',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          DropdownButtonFormField<String>(
            value: _settings['autoLockTimeout'] as String,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.w,
                vertical: 1.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'immediately',
                child: Text('Immediately'),
              ),
              DropdownMenuItem(value: '1min', child: Text('1 minute')),
              DropdownMenuItem(value: '5min', child: Text('5 minutes')),
              DropdownMenuItem(value: '15min', child: Text('15 minutes')),
              DropdownMenuItem(value: 'never', child: Text('Never')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _settings['autoLockTimeout'] = value;
                });
                widget.onSettingsChanged(_settings);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSharingPreferences() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Dream Sharing Preferences',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Column(
            children: [
              RadioListTile<String>(
                title: Text(
                  'Private (Only me)',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                value: 'private',
                groupValue: _settings['sharingPreference'] as String,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _settings['sharingPreference'] = value;
                    });
                    widget.onSettingsChanged(_settings);
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: Text(
                  'Friends only',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                value: 'friends',
                groupValue: _settings['sharingPreference'] as String,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _settings['sharingPreference'] = value;
                    });
                    widget.onSettingsChanged(_settings);
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: Text(
                  'Public (Anonymous)',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                value: 'public',
                groupValue: _settings['sharingPreference'] as String,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _settings['sharingPreference'] = value;
                    });
                    widget.onSettingsChanged(_settings);
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

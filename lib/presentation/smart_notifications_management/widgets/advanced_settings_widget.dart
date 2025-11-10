import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class AdvancedSettingsWidget extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const AdvancedSettingsWidget({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<AdvancedSettingsWidget> createState() => _AdvancedSettingsWidgetState();
}

class _AdvancedSettingsWidgetState extends State<AdvancedSettingsWidget> {
  final List<Map<String, dynamic>> _advancedFeatures = [
    {
      'key': 'locationAdjustments',
      'name': 'Location-Based Adjustments',
      'description': 'Automatically adjust for travel and time zones',
      'icon': Icons.location_on,
      'color': AppTheme.accentPurple,
      'warning': 'Requires location permissions',
      'details': [
        'Time zone detection',
        'Travel mode activation',
        'Jet lag adaptation',
        'Location-based Do Not Disturb',
      ],
    },
    {
      'key': 'seasonalTiming',
      'name': 'Seasonal Timing Modifications',
      'description': 'Adapt notifications based on daylight and seasons',
      'icon': Icons.wb_sunny,
      'color': AppTheme.warningColor,
      'warning': 'Experimental feature',
      'details': [
        'Daylight saving adjustments',
        'Seasonal sleep pattern changes',
        'Natural circadian alignment',
        'Sunrise/sunset synchronization',
      ],
    },
    {
      'key': 'travelMode',
      'name': 'Travel Mode',
      'description': 'Smart adaptation for frequent travelers',
      'icon': Icons.flight,
      'color': AppTheme.accentPurpleLight,
      'warning': null,
      'details': [
        'Multiple time zone support',
        'Flight schedule integration',
        'Gradual adjustment periods',
        'Travel stress detection',
      ],
    },
    {
      'key': 'accessibilityMode',
      'name': 'Enhanced Accessibility',
      'description': 'Improved support for accessibility needs',
      'icon': Icons.accessibility,
      'color': AppTheme.successColor,
      'warning': null,
      'details': [
        'VoiceOver/TalkBack optimization',
        'High contrast notifications',
        'Vibration pattern customization',
        'Screen reader announcements',
      ],
    },
    {
      'key': 'debugMode',
      'name': 'Developer Debug Mode',
      'description': 'Advanced logging and diagnostic information',
      'icon': Icons.developer_mode,
      'color': AppTheme.textMediumGray,
      'warning': 'For debugging only',
      'details': [
        'Detailed notification logs',
        'Algorithm decision tracking',
        'Performance metrics',
        'Export diagnostic data',
      ],
    },
  ];

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
                  Icons.settings_applications,
                  color: AppTheme.accentPurpleLight,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Advanced Settings',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textWhite,
                  ),
                ),
                Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'BETA',
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Experimental features that enhance notification intelligence',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMediumGray,
              ),
            ),
            SizedBox(height: 3.h),

            // Advanced Features
            Column(
              children: _advancedFeatures.map((feature) {
                return _buildAdvancedFeature(feature);
              }).toList(),
            ),

            SizedBox(height: 3.h),

            // System Integration Info
            _buildSystemIntegration(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFeature(Map<String, dynamic> feature) {
    final isEnabled = widget.settings[feature['key']] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 2.h),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: (feature['color'] as Color).withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            feature['icon'] as IconData,
            color: feature['color'] as Color,
            size: 5.w,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feature['name'],
              style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              feature['description'],
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textLightGray,
              ),
            ),
            if (feature['warning'] != null) ...[
              SizedBox(height: 1.h),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.warningColor,
                    size: 3.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    feature['warning'],
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Switch(
          value: isEnabled,
          onChanged: (value) => _updateSetting(feature['key'], value),
        ),
        children: [
          if (isEnabled) ...[
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.cardMediumPurple.withAlpha(128),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feature includes:',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLightGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Column(
                    children:
                        (feature['details'] as List<String>).map((detail) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 0.5.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 1.h),
                              width: 1.w,
                              height: 1.w,
                              decoration: BoxDecoration(
                                color: feature['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                detail,
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textMediumGray,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (feature['key'] == 'locationAdjustments' && isEnabled) ...[
              SizedBox(height: 2.h),
              _buildLocationSettings(),
            ],
            if (feature['key'] == 'debugMode' && isEnabled) ...[
              SizedBox(height: 2.h),
              _buildDebugSettings(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSettings() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentPurple.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Settings',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          _buildLocationOption('Automatic time zone detection', true),
          _buildLocationOption('Travel mode triggers', true),
          _buildLocationOption('Geo-fence quiet zones', false),
        ],
      ),
    );
  }

  Widget _buildLocationOption(String title, bool isEnabled) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Checkbox(
            value: isEnabled,
            onChanged: (value) {
              // Handle location sub-setting change
            },
          ),
          Expanded(
            child: Text(
              title,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textLightGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugSettings() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.textMediumGray.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.textMediumGray.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Options',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportLogs,
                  icon: Icon(Icons.download, size: 4.w),
                  label: Text('Export Logs'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.textMediumGray),
                    foregroundColor: AppTheme.textMediumGray,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearLogs,
                  icon: Icon(Icons.delete_outline, size: 4.w),
                  label: Text('Clear Logs'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.errorColor),
                    foregroundColor: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemIntegration() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardMediumPurple.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderPurple.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.integration_instructions,
                color: AppTheme.accentPurpleLight,
              ),
              SizedBox(width: 2.w),
              Text(
                'System Integration',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildIntegrationStatus('iOS Notification Center', true, 'Connected'),
          _buildIntegrationStatus(
              'Android Notification Channels', true, 'Optimized'),
          _buildIntegrationStatus('Device Do Not Disturb', true, 'Respected'),
          _buildIntegrationStatus(
              'Calendar Integration', false, 'Not Available'),
          _buildIntegrationStatus('Health App Sync', false, 'Disabled'),
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
                    'Advanced features require additional permissions and may impact battery life.',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLightGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationStatus(String name, bool isAvailable, String status) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color:
                isAvailable ? AppTheme.successColor : AppTheme.textMediumGray,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              name,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLightGray,
              ),
            ),
          ),
          Text(
            status,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color:
                  isAvailable ? AppTheme.successColor : AppTheme.textMediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.download, color: AppTheme.textWhite),
            SizedBox(width: 2.w),
            Text('Debug logs exported to device storage'),
          ],
        ),
        backgroundColor: AppTheme.accentPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _clearLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Debug Logs',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        content: Text(
          'This will permanently delete all debug logs. This action cannot be undone.',
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Debug logs cleared'),
                  backgroundColor: AppTheme.errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _updateSetting(String key, dynamic value) {
    final updatedSettings = Map<String, dynamic>.from(widget.settings);
    updatedSettings[key] = value;
    widget.onSettingsChanged(updatedSettings);
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppPreferencesWidget extends StatefulWidget {
  final Map<String, dynamic> appSettings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const AppPreferencesWidget({
    super.key,
    required this.appSettings,
    required this.onSettingsChanged,
  });

  @override
  State<AppPreferencesWidget> createState() => _AppPreferencesWidgetState();
}

class _AppPreferencesWidgetState extends State<AppPreferencesWidget> {
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    _settings = Map<String, dynamic>.from(widget.appSettings);
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
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'App Preferences',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSwitchTile(
            'Dark Theme',
            'Use dark mode for better nighttime viewing',
            'darkTheme',
            'dark_mode',
          ),
          SizedBox(height: 2.h),
          _buildTextSizeSelector(),
          SizedBox(height: 2.h),
          _buildVoiceQualitySelector(),
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

  Widget _buildTextSizeSelector() {
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
                iconName: 'text_fields',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Text Size',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text('A', style: AppTheme.lightTheme.textTheme.bodySmall),
              Expanded(
                child: Slider(
                  value: _settings['textSize'] as double,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label:
                      '${((_settings['textSize'] as double) * 100).round()}%',
                  onChanged: (value) {
                    setState(() {
                      _settings['textSize'] = value;
                    });
                    widget.onSettingsChanged(_settings);
                  },
                ),
              ),
              Text('A', style: AppTheme.lightTheme.textTheme.titleLarge),
            ],
          ),
          Center(
            child: Text(
              'Sample text at ${((_settings['textSize'] as double) * 100).round()}% size',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontSize: 14 * (_settings['textSize'] as double),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceQualitySelector() {
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
                iconName: 'mic',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Voice Recording Quality',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          DropdownButtonFormField<String>(
            initialValue: _settings['voiceQuality'] as String,
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
                value: 'low',
                child: Text('Low (Saves storage)'),
              ),
              DropdownMenuItem(
                value: 'medium',
                child: Text('Medium (Balanced)'),
              ),
              DropdownMenuItem(
                value: 'high',
                child: Text('High (Best quality)'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _settings['voiceQuality'] = value;
                });
                widget.onSettingsChanged(_settings);
              }
            },
          ),
          SizedBox(height: 1.h),
          Text(
            _getQualityDescription(_settings['voiceQuality'] as String),
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getQualityDescription(String quality) {
    switch (quality) {
      case 'low':
        return 'Approximately 1 MB per 10 minutes of recording';
      case 'medium':
        return 'Approximately 2 MB per 10 minutes of recording';
      case 'high':
        return 'Approximately 4 MB per 10 minutes of recording';
      default:
        return '';
    }
  }
}

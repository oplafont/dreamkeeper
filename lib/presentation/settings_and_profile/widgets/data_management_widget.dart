import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';

class DataManagementWidget extends StatefulWidget {
  final Map<String, dynamic> dataSettings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const DataManagementWidget({
    super.key,
    required this.dataSettings,
    required this.onSettingsChanged,
  });

  @override
  State<DataManagementWidget> createState() => _DataManagementWidgetState();
}

class _DataManagementWidgetState extends State<DataManagementWidget> {
  late Map<String, dynamic> _settings;
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _settings = Map<String, dynamic>.from(widget.dataSettings);
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
                iconName: 'storage',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Data Management',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildCloudSyncStatus(),
          SizedBox(height: 2.h),
          _buildStorageUsage(),
          SizedBox(height: 2.h),
          _buildBackupRestore(),
          SizedBox(height: 2.h),
          _buildExportOptions(),
        ],
      ),
    );
  }

  Widget _buildCloudSyncStatus() {
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
            iconName: 'cloud_sync',
            color: _settings['cloudSyncEnabled'] as bool
                ? Colors.green
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cloud Sync',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _settings['cloudSyncEnabled'] as bool
                      ? 'Last synced: ${_settings['lastSyncTime']}'
                      : 'Sync disabled',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: _settings['cloudSyncEnabled'] as bool,
            onChanged: (value) {
              setState(() {
                _settings['cloudSyncEnabled'] = value;
                if (value) {
                  _settings['lastSyncTime'] = 'Just now';
                }
              });
              widget.onSettingsChanged(_settings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageUsage() {
    final double usagePercentage = (_settings['storageUsed'] as double) /
        (_settings['storageTotal'] as double);

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
                iconName: 'pie_chart',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Storage Usage',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_settings['storageUsed'] as double).toStringAsFixed(1)} MB used',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '${(_settings['storageTotal'] as double).toStringAsFixed(1)} MB total',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: usagePercentage,
            backgroundColor: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(
              usagePercentage > 0.8
                  ? Colors.red
                  : usagePercentage > 0.6
                      ? Colors.orange
                      : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupRestore() {
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
                iconName: 'backup',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Backup & Restore',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _createBackup,
                  icon: CustomIconWidget(
                    iconName: 'cloud_upload',
                    color: Colors.white,
                    size: 4.w,
                  ),
                  label: Text('Create Backup'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isImporting ? null : _restoreBackup,
                  icon: _isImporting
                      ? SizedBox(
                          width: 4.w,
                          height: 4.w,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : CustomIconWidget(
                          iconName: 'cloud_download',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                  label: Text(_isImporting ? 'Restoring...' : 'Restore'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions() {
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
                iconName: 'file_download',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Export Dreams',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  'PDF',
                  'picture_as_pdf',
                  () => _exportData('pdf'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildExportButton(
                  'CSV',
                  'table_chart',
                  () => _exportData('csv'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildExportButton(
                  'JSON',
                  'code',
                  () => _exportData('json'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    String format,
    String iconName,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: _isExporting ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isExporting
              ? SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
          SizedBox(height: 0.5.h),
          Text(format, style: AppTheme.lightTheme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      final backupData = {
        'dreams': _getMockDreamData(),
        'settings': _settings,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      final jsonString = json.encode(backupData);
      final filename =
          'dreamdecoder_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      await _downloadFile(jsonString, filename);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup created successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create backup')));
      }
    }
  }

  Future<void> _restoreBackup() async {
    setState(() {
      _isImporting = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        List<int>? bytes;
        if (kIsWeb) {
          bytes = result.files.first.bytes;
        } else {
          bytes = await File(result.files.first.path!).readAsBytes();
        }

        final jsonString = utf8.decode(bytes!);
        final backupData = json.decode(jsonString) as Map<String, dynamic>;

        // Validate backup data structure
        if (backupData.containsKey('dreams') &&
            backupData.containsKey('settings')) {
          setState(() {
            _settings = Map<String, dynamic>.from(
              backupData['settings'] as Map<String, dynamic>,
            );
          });
          widget.onSettingsChanged(_settings);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Backup restored successfully')),
            );
          }
        } else {
          throw Exception('Invalid backup file format');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to restore backup')));
      }
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _exportData(String format) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final dreamData = _getMockDreamData();
      String content;
      String filename;

      switch (format.toLowerCase()) {
        case 'pdf':
          content = _generatePDFContent(dreamData);
          filename =
              'dreams_export_${DateTime.now().millisecondsSinceEpoch}.txt';
          break;
        case 'csv':
          content = _generateCSVContent(dreamData);
          filename =
              'dreams_export_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'json':
          content = json.encode(dreamData);
          filename =
              'dreams_export_${DateTime.now().millisecondsSinceEpoch}.json';
          break;
        default:
          throw Exception('Unsupported format');
      }

      await _downloadFile(content, filename);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dreams exported as $format successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export dreams')));
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  List<Map<String, dynamic>> _getMockDreamData() {
    return [
      {
        'id': 1,
        'title': 'Flying Over Mountains',
        'content':
            'I was soaring above snow-capped peaks with incredible freedom and clarity.',
        'date': '2025-10-28',
        'mood': 'Euphoric',
        'tags': ['flying', 'mountains', 'freedom'],
        'lucid': true,
      },
      {
        'id': 2,
        'title': 'Lost in a Library',
        'content':
            'Wandering through endless corridors of books, searching for something important.',
        'date': '2025-10-27',
        'mood': 'Anxious',
        'tags': ['library', 'searching', 'lost'],
        'lucid': false,
      },
    ];
  }

  String _generateCSVContent(List<Map<String, dynamic>> dreams) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Title,Content,Mood,Tags,Lucid');

    for (final dream in dreams) {
      final tags = (dream['tags'] as List).join(';');
      buffer.writeln(
        '"${dream['date']}","${dream['title']}","${dream['content']}","${dream['mood']}","$tags","${dream['lucid']}"',
      );
    }

    return buffer.toString();
  }

  String _generatePDFContent(List<Map<String, dynamic>> dreams) {
    final buffer = StringBuffer();
    buffer.writeln('DREAM JOURNAL EXPORT');
    buffer.writeln('Generated on: ${DateTime.now().toString()}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final dream in dreams) {
      buffer.writeln('Date: ${dream['date']}');
      buffer.writeln('Title: ${dream['title']}');
      buffer.writeln('Mood: ${dream['mood']}');
      buffer.writeln('Lucid: ${dream['lucid'] ? 'Yes' : 'No'}');
      buffer.writeln('Tags: ${(dream['tags'] as List).join(', ')}');
      buffer.writeln();
      buffer.writeln('Content:');
      buffer.writeln(dream['content']);
      buffer.writeln();
      buffer.writeln('-' * 30);
      buffer.writeln();
    }

    return buffer.toString();
  }
}
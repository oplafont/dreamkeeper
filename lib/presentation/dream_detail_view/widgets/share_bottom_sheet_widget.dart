import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';

class ShareBottomSheetWidget extends StatelessWidget {
  final Map<String, dynamic> dreamData;

  const ShareBottomSheetWidget({Key? key, required this.dreamData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Share Dream',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Choose how you want to share your dream',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          _buildShareOption(
            context,
            'Anonymous Sharing',
            'Share without personal information',
            'shield',
            () => _shareAnonymously(context),
          ),
          _buildShareOption(
            context,
            'Trusted Contacts',
            'Share with selected contacts only',
            'people',
            () => _shareWithContacts(context),
          ),
          _buildShareOption(
            context,
            'Export as PDF',
            'Save dream as PDF document',
            'picture_as_pdf',
            () => _exportAsPDF(context),
          ),
          _buildShareOption(
            context,
            'Export as Text',
            'Save dream as text file',
            'text_snippet',
            () => _exportAsText(context),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.3,
            ),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _shareAnonymously(BuildContext context) {
    final title = dreamData['title'] as String? ?? 'Untitled Dream';
    final description = dreamData['description'] as String? ?? '';
    final mood = dreamData['mood'] as String? ?? 'Unknown';
    final tags = (dreamData['tags'] as List?)?.cast<String>() ?? [];

    final shareText = '''
Dream: $title

$description

Mood: $mood
Tags: ${tags.join(', ')}

Shared anonymously from DreamKeeper
''';

    Share.share(shareText, subject: 'Dream: $title');
    Navigator.of(context).pop();
  }

  void _shareWithContacts(BuildContext context) {
    final title = dreamData['title'] as String? ?? 'Untitled Dream';
    final description = dreamData['description'] as String? ?? '';
    final creationDate =
        dreamData['creationDate'] as DateTime? ?? DateTime.now();
    final mood = dreamData['mood'] as String? ?? 'Unknown';
    final sleepQuality = dreamData['sleepQuality'] as double? ?? 0.0;
    final tags = (dreamData['tags'] as List?)?.cast<String>() ?? [];

    final shareText = '''
I wanted to share this dream with you:

Title: $title
Date: ${creationDate.day}/${creationDate.month}/${creationDate.year}

$description

Sleep Quality: ${sleepQuality.toStringAsFixed(1)}/5.0
Mood: $mood
Tags: ${tags.join(', ')}

Shared from DreamKeeper
''';

    Share.share(shareText, subject: 'Dream: $title');
    Navigator.of(context).pop();
  }

  Future<void> _exportAsPDF(BuildContext context) async {
    try {
      final title = dreamData['title'] as String? ?? 'Untitled Dream';
      final description = dreamData['description'] as String? ?? '';
      final creationDate =
          dreamData['creationDate'] as DateTime? ?? DateTime.now();
      final mood = dreamData['mood'] as String? ?? 'Unknown';
      final sleepQuality = dreamData['sleepQuality'] as double? ?? 0.0;
      final tags = (dreamData['tags'] as List?)?.cast<String>() ?? [];

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'DreamKeeper Export',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Date: ${creationDate.day}/${creationDate.month}/${creationDate.year}',
                ),
                pw.Text(
                  'Sleep Quality: ${sleepQuality.toStringAsFixed(1)}/5.0',
                ),
                pw.Text('Mood: $mood'),
                if (tags.isNotEmpty) pw.Text('Tags: ${tags.join(', ')}'),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Dream Description:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(description),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final filename =
          'dream_${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute("download", filename)
              ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes);

        Share.shareXFiles([XFile(file.path)], text: 'Dream PDF Export');
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dream exported as PDF successfully'),
          backgroundColor: AppTheme.getSuccessColor(),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  Future<void> _exportAsText(BuildContext context) async {
    try {
      final title = dreamData['title'] as String? ?? 'Untitled Dream';
      final description = dreamData['description'] as String? ?? '';
      final creationDate =
          dreamData['creationDate'] as DateTime? ?? DateTime.now();
      final mood = dreamData['mood'] as String? ?? 'Unknown';
      final sleepQuality = dreamData['sleepQuality'] as double? ?? 0.0;
      final tags = (dreamData['tags'] as List?)?.cast<String>() ?? [];

      final content = '''
DreamKeeper Export
==================

Title: $title
Date: ${creationDate.day}/${creationDate.month}/${creationDate.year}
Sleep Quality: ${sleepQuality.toStringAsFixed(1)}/5.0
Mood: $mood
Tags: ${tags.join(', ')}

Dream Description:
------------------
$description

Exported on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
''';

      final filename =
          'dream_${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.txt';

      if (kIsWeb) {
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute("download", filename)
              ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);

        Share.shareXFiles([XFile(file.path)], text: 'Dream Text Export');
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dream exported as text successfully'),
          backgroundColor: AppTheme.getSuccessColor(),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export text file'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }
}
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/dream.dart';
import 'logger_service.dart';

/// Service for exporting dreams to various formats
class ExportService {
  static final ExportService _instance = ExportService._internal();
  static ExportService get instance => _instance;

  ExportService._internal();

  /// Export dreams to PDF format
  Future<File?> exportToPDF({
    required List<Dream> dreams,
    String? title,
    bool includeAnalysis = true,
    bool anonymize = false,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildPDFHeader(title ?? 'Dream Journal Export'),
          footer: (context) => _buildPDFFooter(context),
          build: (context) => [
            pw.SizedBox(height: 20),
            ...dreams.map((dream) => _buildDreamEntry(
              dream,
              includeAnalysis: includeAnalysis,
              anonymize: anonymize,
            )),
          ],
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'dreamkeeper_export_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(await pdf.save());

      log.info('PDF exported to: ${file.path}');
      return file;
    } catch (e) {
      log.error('Failed to export to PDF', e);
      return null;
    }
  }

  pw.Widget _buildPDFHeader(String title) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.purple,
            width: 2,
          ),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple900,
            ),
          ),
          pw.Text(
            'DreamKeeper',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  pw.Widget _buildDreamEntry(
    Dream dream, {
    bool includeAnalysis = true,
    bool anonymize = false,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.purple200,
          width: 1,
        ),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Title and Date
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  dream.displayTitle,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple900,
                  ),
                ),
              ),
              pw.Text(
                dream.formattedDate,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          // Metadata
          pw.Row(
            children: [
              if (dream.mood != null)
                _buildMetadataChip('Mood: ${dream.mood}'),
              if (dream.sleepQuality != null)
                _buildMetadataChip('Sleep: ${dream.sleepQuality}'),
              if (dream.clarityScore != null)
                _buildMetadataChip('Clarity: ${dream.clarityScore}/10'),
            ],
          ),

          pw.SizedBox(height: 10),

          // Content
          pw.Text(
            dream.content,
            style: const pw.TextStyle(
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),

          // AI Analysis
          if (includeAnalysis && dream.hasAIAnalysis) ...[
            pw.SizedBox(height: 15),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'AI Analysis',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple800,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  if (dream.aiSymbols.isNotEmpty)
                    pw.Text(
                      'Symbols: ${dream.aiSymbols.join(", ")}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  if (dream.aiEmotions.isNotEmpty)
                    pw.Text(
                      'Emotions: ${dream.aiEmotions.join(", ")}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  if (dream.aiThemes.isNotEmpty)
                    pw.Text(
                      'Themes: ${dream.aiThemes.join(", ")}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                ],
              ),
            ),
          ],

          // Tags
          if (dream.tags.isNotEmpty || dream.aiTags.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                ...dream.tags.map((tag) => _buildTag(tag, false)),
                ...dream.aiTags.map((tag) => _buildTag(tag, true)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildMetadataChip(String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 8),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  pw.Widget _buildTag(String tag, bool isAI) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: isAI ? PdfColors.purple100 : PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        isAI ? '# $tag' : '#$tag',
        style: pw.TextStyle(
          fontSize: 8,
          color: isAI ? PdfColors.purple700 : PdfColors.grey700,
        ),
      ),
    );
  }

  /// Export dreams to JSON format
  Future<File?> exportToJSON({
    required List<Dream> dreams,
    bool anonymize = false,
  }) async {
    try {
      final dreamsJson = dreams.map((d) {
        final json = d.toJson();
        if (anonymize) {
          json.remove('user_id');
        }
        return json;
      }).toList();

      final content = '''
{
  "exported_at": "${DateTime.now().toIso8601String()}",
  "total_dreams": ${dreams.length},
  "dreams": ${_prettyJson(dreamsJson)}
}
''';

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'dreamkeeper_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(content);

      log.info('JSON exported to: ${file.path}');
      return file;
    } catch (e) {
      log.error('Failed to export to JSON', e);
      return null;
    }
  }

  /// Export dreams to CSV format
  Future<File?> exportToCSV({
    required List<Dream> dreams,
    bool anonymize = false,
  }) async {
    try {
      final buffer = StringBuffer();

      // Header
      buffer.writeln(
        'Date,Title,Content,Mood,Sleep Quality,Clarity Score,Is Lucid,Is Nightmare,Is Recurring,Tags,AI Tags,AI Symbols,AI Emotions,AI Themes',
      );

      // Rows
      for (final dream in dreams) {
        buffer.writeln([
          _escapeCSV(dream.formattedDate),
          _escapeCSV(dream.title ?? ''),
          _escapeCSV(dream.content),
          _escapeCSV(dream.mood ?? ''),
          _escapeCSV(dream.sleepQuality ?? ''),
          dream.clarityScore?.toString() ?? '',
          dream.isLucid ? 'Yes' : 'No',
          dream.isNightmare ? 'Yes' : 'No',
          dream.isRecurring ? 'Yes' : 'No',
          _escapeCSV(dream.tags.join('; ')),
          _escapeCSV(dream.aiTags.join('; ')),
          _escapeCSV(dream.aiSymbols.join('; ')),
          _escapeCSV(dream.aiEmotions.join('; ')),
          _escapeCSV(dream.aiThemes.join('; ')),
        ].join(','));
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'dreamkeeper_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(buffer.toString());

      log.info('CSV exported to: ${file.path}');
      return file;
    } catch (e) {
      log.error('Failed to export to CSV', e);
      return null;
    }
  }

  /// Share a file
  Future<bool> shareFile(File file, {String? subject}) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: subject ?? 'DreamKeeper Export',
      );
      return true;
    } catch (e) {
      log.error('Failed to share file', e);
      return false;
    }
  }

  /// Share text content
  Future<bool> shareText(String text, {String? subject}) async {
    try {
      await Share.share(text, subject: subject);
      return true;
    } catch (e) {
      log.error('Failed to share text', e);
      return false;
    }
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _prettyJson(dynamic json) {
    // Simple pretty print for JSON
    return json.toString();
  }
}

/// Global export service instance
final exportService = ExportService.instance;

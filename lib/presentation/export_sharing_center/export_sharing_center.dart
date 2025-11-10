import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './widgets/professional_reports_widget.dart';
import './widgets/research_export_widget.dart';
import './widgets/personal_documentation_widget.dart';
import './widgets/sharing_controls_widget.dart';
import './widgets/privacy_settings_widget.dart';
import './widgets/export_preview_widget.dart';
import './widgets/batch_export_widget.dart';
import './widgets/cloud_storage_widget.dart';

class ExportSharingCenter extends StatefulWidget {
  const ExportSharingCenter({super.key});

  @override
  State<ExportSharingCenter> createState() => _ExportSharingCenterState();
}

class _ExportSharingCenterState extends State<ExportSharingCenter>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;
  String _selectedExportType = 'professional';
  Map<String, bool> _privacySettings = {
    'anonymize_personal_data': true,
    'include_metadata': false,
    'hipaa_compliant': true,
    'filter_sensitive_content': true,
  };

  final List<String> _exportTypes = [
    'Professional Report',
    'Research Export',
    'Personal Documentation',
    'Batch Export',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F051F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1B69),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Export & Sharing Center',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.privacy_tip, color: Color(0xFF8B5CF6)),
            onPressed: () => _showPrivacySettings(),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF8B5CF6)),
            onPressed: () => _showHelpDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8B5CF6),
          labelColor: const Color(0xFF8B5CF6),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: const [
            Tab(text: 'Professional'),
            Tab(text: 'Research'),
            Tab(text: 'Personal'),
            Tab(text: 'Batch'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Processing Indicator
          if (_isProcessing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E1B4B),
              child: Row(
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF8B5CF6),
                    strokeWidth: 2,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Processing export...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Professional Reports Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        'Therapeutic Consultation Reports',
                        'Generate detailed PDF reports optimized for therapist consultation',
                        Icons.medical_services,
                      ),
                      const SizedBox(height: 16),
                      ProfessionalReportsWidget(
                        privacySettings: _privacySettings,
                        onExportTap: (reportType) => _handleExport(reportType),
                        onPreviewTap: (reportType) => _showPreview(reportType),
                      ),
                    ],
                  ),
                ),

                // Research Export Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        'Research Participation',
                        'Contribute anonymized data to dream research studies',
                        Icons.science,
                      ),
                      const SizedBox(height: 16),
                      ResearchExportWidget(
                        privacySettings: _privacySettings,
                        onExportTap:
                            (researchType) => _handleExport(researchType),
                        onConsentTap: () => _showConsentDialog(),
                      ),
                    ],
                  ),
                ),

                // Personal Documentation Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        'Personal Documentation',
                        'Export your dream data in various formats for personal use',
                        Icons.folder_open,
                      ),
                      const SizedBox(height: 16),
                      PersonalDocumentationWidget(
                        onExportTap: (format) => _handleExport(format),
                        onCloudSaveTap: (service) => _handleCloudSave(service),
                      ),
                    ],
                  ),
                ),

                // Batch Export Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        'Batch Operations',
                        'Export multiple date ranges and categories simultaneously',
                        Icons.sync,
                      ),
                      const SizedBox(height: 16),
                      BatchExportWidget(
                        onBatchExportTap:
                            (config) => _handleBatchExport(config),
                        isProcessing: _isProcessing,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick Action Bar
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1B4B),
              border: Border(
                top: BorderSide(color: Color(0xFF4C1D95), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSharingOptions(),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCloudStorageOptions(),
                    icon: const Icon(Icons.cloud_upload, size: 18),
                    label: const Text('Cloud Save'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C1D95).withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: PrivacySettingsWidget(
                    currentSettings: _privacySettings,
                    scrollController: scrollController,
                    onSettingsChanged: (settings) {
                      setState(() {
                        _privacySettings = settings;
                      });
                    },
                  ),
                ),
          ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(maxHeight: 70.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.help_outline,
                    color: Color(0xFF8B5CF6),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Export & Sharing Help',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHelpItem(
                            'Professional Reports',
                            'Generate HIPAA-compliant PDF reports for therapist consultation with anonymized identifiers.',
                          ),
                          _buildHelpItem(
                            'Research Export',
                            'Contribute to dream research with full privacy controls and IRB compliance.',
                          ),
                          _buildHelpItem(
                            'Personal Documentation',
                            'Export your data in PDF, CSV, or JSON formats with customizable date ranges.',
                          ),
                          _buildHelpItem(
                            'Privacy Controls',
                            'All exports use automatic personal identifier removal and consent management.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showSharingOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => SharingControlsWidget(
            onShareOptionTap: (option) {
              Navigator.pop(context);
              _handleShare(option);
            },
          ),
    );
  }

  void _showCloudStorageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => CloudStorageWidget(
            onCloudServiceTap: (service) {
              Navigator.pop(context);
              _handleCloudSave(service);
            },
          ),
    );
  }

  void _showConsentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(maxHeight: 80.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user,
                    color: Color(0xFF10B981),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Research Consent',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        'By participating in dream research, you consent to sharing anonymized dream data with approved research institutions. Your personal identifiers are automatically removed, and you maintain full control over which data categories to include.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white70),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _processResearchConsent();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('I Consent'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showPreview(String reportType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: const Color(0xFF0F051F),
              appBar: AppBar(
                backgroundColor: const Color(0xFF2D1B69),
                title: Text('Preview: $reportType'),
              ),
              body: ExportPreviewWidget(
                reportType: reportType,
                privacySettings: _privacySettings,
                onEditTap: () => Navigator.pop(context),
                onExportTap: () {
                  Navigator.pop(context);
                  _handleExport(reportType);
                },
              ),
            ),
      ),
    );
  }

  Future<void> _handleExport(String exportType) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate export processing
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$exportType exported successfully'),
            backgroundColor: const Color(0xFF10B981),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Handle view exported file
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleBatchExport(Map<String, dynamic> config) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate batch export processing
      await Future.delayed(const Duration(seconds: 5));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch export completed successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _handleShare(String shareOption) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing via $shareOption...'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
    );
  }

  void _handleCloudSave(String service) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saving to $service...'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
    );
  }

  void _processResearchConsent() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Research consent recorded. You can now export research data.',
        ),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ExportFunctionalityWidget extends StatefulWidget {
  final Map<String, dynamic> filters;
  final Function(String) onExport;

  const ExportFunctionalityWidget({
    super.key,
    required this.filters,
    required this.onExport,
  });

  @override
  State<ExportFunctionalityWidget> createState() =>
      _ExportFunctionalityWidgetState();
}

class _ExportFunctionalityWidgetState extends State<ExportFunctionalityWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFormat = 'PDF';
  bool _includeVisualizations = true;
  bool _includeStatistics = true;
  bool _includeRecommendations = true;

  final List<Map<String, dynamic>> _exportFormats = [
    {
      'format': 'PDF',
      'icon': Icons.picture_as_pdf,
      'color': Colors.red,
      'description': 'Comprehensive visual report with charts and analysis',
      'fileSize': '~2-5 MB',
    },
    {
      'format': 'CSV',
      'icon': Icons.table_chart,
      'color': Colors.green,
      'description': 'Raw data export for spreadsheet analysis',
      'fileSize': '~100-500 KB',
    },
    {
      'format': 'JSON',
      'icon': Icons.code,
      'color': Colors.blue,
      'description': 'Structured data for technical analysis',
      'fileSize': '~50-200 KB',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.file_download, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Export Analytics Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a comprehensive report based on your current filters',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Current Filters Summary
            _buildCurrentFiltersSummary(),
            const SizedBox(height: 20),

            // Export Format Selection
            const Text(
              'Select Export Format',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ...List.generate(_exportFormats.length, (index) {
              final format = _exportFormats[index];
              return _buildFormatOption(format);
            }),

            const SizedBox(height: 20),

            // Export Options
            const Text(
              'Include in Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildCheckboxOption(
              'Data Visualizations',
              'Charts, graphs, and visual analytics',
              _includeVisualizations,
              (value) => setState(() => _includeVisualizations = value),
            ),
            _buildCheckboxOption(
              'Statistical Summaries',
              'Numerical data and trend analysis',
              _includeStatistics,
              (value) => setState(() => _includeStatistics = value),
            ),
            _buildCheckboxOption(
              'AI Recommendations',
              'Personalized insights and suggestions',
              _includeRecommendations,
              (value) => setState(() => _includeRecommendations = value),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getFormatIcon(_selectedFormat), size: 18),
                        const SizedBox(width: 8),
                        Text('Export $_selectedFormat'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentFiltersSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.purple, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Current Filters',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildFilterChip(
                  'Time Range', widget.filters['timeRange'] ?? 'All'),
              if (widget.filters['emotions']?.isNotEmpty == true)
                _buildFilterChip('Emotions',
                    '${(widget.filters['emotions'] as List).length} selected'),
              if (widget.filters['sleepQuality'] != 'All')
                _buildFilterChip(
                    'Sleep Quality', widget.filters['sleepQuality'] ?? 'All'),
              if (widget.filters['tags']?.isNotEmpty == true)
                _buildFilterChip('Tags',
                    '${(widget.filters['tags'] as List).length} selected'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(51),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }

  Widget _buildFormatOption(Map<String, dynamic> format) {
    final isSelected = _selectedFormat == format['format'];

    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = format['format']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? format['color'].withAlpha(26)
              : Colors.grey.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? format['color'].withAlpha(128)
                : Colors.grey.withAlpha(51),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              format['icon'],
              color: isSelected ? format['color'] : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format['format'],
                    style: TextStyle(
                      color: isSelected ? format['color'] : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format['description'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'File size: ${format['fileSize']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: format['format'],
              groupValue: _selectedFormat,
              onChanged: (value) => setState(() => _selectedFormat = value!),
              activeColor: format['color'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: Colors.purple,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'CSV':
        return Icons.table_chart;
      case 'JSON':
        return Icons.code;
      default:
        return Icons.file_download;
    }
  }

  void _generateReport() {
    // Simulate report generation process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.purple),
              const SizedBox(height: 16),
              const Text(
                'Generating Report...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Processing analytics data and creating $_selectedFormat report',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate processing time
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close progress dialog
      widget.onExport(_selectedFormat);
    });
  }
}

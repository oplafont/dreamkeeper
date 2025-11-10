import 'package:flutter/material.dart';


class PersonalDocumentationWidget extends StatefulWidget {
  final Function(String) onExportTap;
  final Function(String) onCloudSaveTap;

  const PersonalDocumentationWidget({
    super.key,
    required this.onExportTap,
    required this.onCloudSaveTap,
  });

  @override
  State<PersonalDocumentationWidget> createState() =>
      _PersonalDocumentationWidgetState();
}

class _PersonalDocumentationWidgetState
    extends State<PersonalDocumentationWidget> {
  String _selectedFormat = 'PDF';
  DateTimeRange? _selectedDateRange;
  List<String> _selectedCategories = ['Dreams', 'Sleep Quality'];
  bool _includeVisuals = true;
  bool _includeAnalytics = false;
  String _exportQuality = 'Standard';

  final List<Map<String, dynamic>> _exportFormats = [
    {
      'format': 'PDF',
      'title': 'PDF Document',
      'description': 'Formatted document with images and charts',
      'icon': Icons.picture_as_pdf,
      'color': Color(0xFFEF4444),
    },
    {
      'format': 'CSV',
      'title': 'CSV Spreadsheet',
      'description': 'Raw data for analysis in Excel or Google Sheets',
      'icon': Icons.table_chart,
      'color': Color(0xFF10B981),
    },
    {
      'format': 'JSON',
      'title': 'JSON Data',
      'description': 'Structured data for developers and advanced users',
      'icon': Icons.code,
      'color': Color(0xFF8B5CF6),
    },
    {
      'format': 'TXT',
      'title': 'Plain Text',
      'description': 'Simple text format for basic documentation',
      'icon': Icons.text_snippet,
      'color': Color(0xFF6B7280),
    },
  ];

  final List<String> _categories = [
    'Dreams',
    'Sleep Quality',
    'Mood Patterns',
    'Lucid Dreams',
    'Nightmares',
    'Sleep Environment',
    'Dream Tags',
  ];

  final List<String> _qualityOptions = ['Basic', 'Standard', 'High Quality'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Export Format Selection
        _buildSectionTitle('Export Format'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _exportFormats.length,
          itemBuilder: (context, index) {
            return _buildFormatCard(_exportFormats[index]);
          },
        ),

        const SizedBox(height: 24),

        // Date Range Selection
        _buildSectionTitle('Date Range'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDateRange,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF312E81),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4C1D95)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.date_range,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateRange != null
                        ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                        : 'Select date range',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Category Selection
        _buildSectionTitle('Data Categories'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  backgroundColor: const Color(0xFF312E81),
                  selectedColor: const Color(0xFF8B5CF6),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color:
                        isSelected
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF4C1D95),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: 24),

        // Additional Options
        _buildSectionTitle('Additional Options'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF312E81),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4C1D95)),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(
                  'Include Visual Analytics',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Charts, graphs, and visual summaries',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                value: _includeVisuals,
                onChanged: (value) {
                  setState(() {
                    _includeVisuals = value;
                  });
                },
                activeColor: const Color(0xFF8B5CF6),
                dense: true,
              ),
              SwitchListTile(
                title: const Text(
                  'Include Advanced Analytics',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Pattern analysis and correlations',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                value: _includeAnalytics,
                onChanged: (value) {
                  setState(() {
                    _includeAnalytics = value;
                  });
                },
                activeColor: const Color(0xFF8B5CF6),
                dense: true,
              ),
              const Divider(color: Color(0xFF4C1D95)),
              Row(
                children: [
                  const Text(
                    'Export Quality:',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _exportQuality,
                    dropdownColor: const Color(0xFF1E1B4B),
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox.shrink(),
                    onChanged: (value) {
                      setState(() {
                        _exportQuality = value!;
                      });
                    },
                    items:
                        _qualityOptions.map((quality) {
                          return DropdownMenuItem(
                            value: quality,
                            child: Text(quality),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Export Size Estimation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4C1D95)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated Export Size',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _calculateExportSize(),
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action Buttons
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _selectedCategories.isNotEmpty
                        ? () => widget.onExportTap(_selectedFormat)
                        : null,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export to Device'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _selectedCategories.isNotEmpty
                            ? () => widget.onCloudSaveTap('Google Drive')
                            : null,
                    icon: const Icon(Icons.cloud_upload, size: 16),
                    label: const Text('Google Drive'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _selectedCategories.isNotEmpty
                            ? () => widget.onCloudSaveTap('iCloud')
                            : null,
                    icon: const Icon(Icons.cloud, size: 16),
                    label: const Text('iCloud'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _selectedCategories.isNotEmpty
                            ? () => widget.onCloudSaveTap('Dropbox')
                            : null,
                    icon: const Icon(Icons.folder, size: 16),
                    label: const Text('Dropbox'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: const BorderSide(color: Color(0xFF8B5CF6)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFormatCard(Map<String, dynamic> format) {
    final isSelected = _selectedFormat == format['format'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFormat = format['format'];
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? format['color'].withAlpha(26)
                  : const Color(0xFF312E81),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? format['color'] : const Color(0xFF4C1D95),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  format['icon'] as IconData,
                  color: isSelected ? format['color'] : Colors.white70,
                  size: 20,
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, color: format['color'], size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              format['title'],
              style: TextStyle(
                color: isSelected ? format['color'] : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              format['description'],
              style: const TextStyle(color: Colors.white60, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              surface: Color(0xFF1E1B4B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _calculateExportSize() {
    int baseSize = _selectedCategories.length * 2; // 2MB per category
    if (_includeVisuals) baseSize += 5; // Additional 5MB for visuals
    if (_includeAnalytics) baseSize += 3; // Additional 3MB for analytics

    switch (_exportQuality) {
      case 'High Quality':
        baseSize = (baseSize * 1.5).round();
        break;
      case 'Basic':
        baseSize = (baseSize * 0.7).round();
        break;
    }

    if (_selectedFormat == 'PDF') {
      return '~${baseSize}MB PDF document';
    } else if (_selectedFormat == 'CSV') {
      return '~${(baseSize * 0.3).round()}MB spreadsheet';
    } else if (_selectedFormat == 'JSON') {
      return '~${(baseSize * 0.4).round()}MB JSON file';
    } else {
      return '~${(baseSize * 0.2).round()}MB text file';
    }
  }
}

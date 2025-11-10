import 'package:flutter/material.dart';

class ProfessionalReportsWidget extends StatefulWidget {
  final Map<String, bool> privacySettings;
  final Function(String) onExportTap;
  final Function(String) onPreviewTap;

  const ProfessionalReportsWidget({
    super.key,
    required this.privacySettings,
    required this.onExportTap,
    required this.onPreviewTap,
  });

  @override
  State<ProfessionalReportsWidget> createState() => _ProfessionalReportsWidgetState();
}

class _ProfessionalReportsWidgetState extends State<ProfessionalReportsWidget> {
  String _selectedDateRange = 'Last 3 months';
  List<String> _selectedCategories = ['Dreams', 'Sleep Quality', 'Mood Patterns'];
  String _selectedFormat = 'Comprehensive Report';

  final List<String> _dateRanges = [
    'Last month',
    'Last 3 months',
    'Last 6 months',
    'Last year',
    'Custom range',
  ];

  final List<String> _categories = [
    'Dreams',
    'Sleep Quality',
    'Mood Patterns',
    'Therapeutic Insights',
    'Progress Tracking',
  ];

  final List<Map<String, dynamic>> _reportFormats = [
{ 'title': 'Comprehensive Report',
'description': 'Complete analysis with all data points and visual analytics',
'duration': '15-20 pages',
'icon': Icons.description,
},
{ 'title': 'Summary Report',
'description': 'Key insights and patterns for quick therapeutic review',
'duration': '5-8 pages',
'icon': Icons.summarize,
},
{ 'title': 'Progress Report',
'description': 'Focus on therapeutic progress and goal achievement',
'duration': '8-12 pages',
'icon': Icons.trending_up,
},
{ 'title': 'Crisis Assessment',
'description': 'Urgent patterns and risk indicators for immediate review',
'duration': '3-5 pages',
'icon': Icons.warning,
},
];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Range Selection
        _buildSectionTitle('Time Period'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF312E81),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4C1D95)),
          ),
          child: DropdownButton<String>(
            value: _selectedDateRange,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            dropdownColor: const Color(0xFF1E1B4B),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                _selectedDateRange = value!;
              });
            },
            items: _dateRanges.map((range) {
              return DropdownMenuItem(
                value: range,
                child: Text(range),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Category Selection
        _buildSectionTitle('Data Categories'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF4C1D95),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Report Format Selection
        _buildSectionTitle('Report Format'),
        const SizedBox(height: 12),
        ..._reportFormats.map((format) => _buildReportFormatCard(format)),

        const SizedBox(height: 24),

        // Privacy Compliance Status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withAlpha(26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF10B981).withAlpha(77)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.security,
                color: Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HIPAA Compliance Active',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'All reports include anonymized patient identifiers and professional formatting',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => widget.onPreviewTap(_selectedFormat),
                icon: const Icon(Icons.preview, size: 18),
                label: const Text('Preview'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _selectedCategories.isNotEmpty
                    ? () => widget.onExportTap(_selectedFormat)
                    : null,
                icon: const Icon(Icons.medical_services, size: 18),
                label: const Text('Generate Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
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

  Widget _buildReportFormatCard(Map<String, dynamic> format) {
    final isSelected = _selectedFormat == format['title'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFormat = format['title'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6).withAlpha(26) : const Color(0xFF312E81),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF4C1D95),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isSelected ? const Color(0xFF8B5CF6) : Colors.white70).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                format['icon'] as IconData,
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format['title'],
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format['duration'],
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF8B5CF6) : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF8B5CF6),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
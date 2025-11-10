import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BatchExportWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onBatchExportTap;
  final bool isProcessing;

  const BatchExportWidget({
    super.key,
    required this.onBatchExportTap,
    required this.isProcessing,
  });

  @override
  State<BatchExportWidget> createState() => _BatchExportWidgetState();
}

class _BatchExportWidgetState extends State<BatchExportWidget> {
  List<Map<String, dynamic>> _exportJobs = [];
  String _selectedFormat = 'PDF';
  bool _separateFiles = true;
  String _namingPattern = 'Dreams_{date_range}_{category}';
  double _processingProgress = 0.0;
  String _currentProcessingJob = '';

  final List<String> _formats = ['PDF', 'CSV', 'JSON', 'TXT'];
  final List<String> _namingPatterns = [
    'Dreams_{date_range}_{category}',
    '{category}_Export_{timestamp}',
    'DreamData_{date}_{format}',
    'Custom_Name_{index}',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Export Jobs Configuration
        _buildSectionTitle('Export Jobs'),
        const SizedBox(height: 12),
        
        // Add New Job Card
        _buildAddJobCard(),
        const SizedBox(height: 16),

        // Existing Jobs List
        if (_exportJobs.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF312E81),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4C1D95)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.queue,
                      color: Color(0xFF8B5CF6),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Export Queue (${_exportJobs.length} jobs)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_exportJobs.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _exportJobs.clear();
                          });
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._exportJobs.asMap().entries.map((entry) {
                  return _buildJobCard(entry.key, entry.value);
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Batch Settings
        _buildSectionTitle('Batch Settings'),
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
              // Format Selection
              Row(
                children: [
                  const Text(
                    'Export Format:',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _selectedFormat,
                    dropdownColor: const Color(0xFF1E1B4B),
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox.shrink(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                    items: _formats.map((format) {
                      return DropdownMenuItem(
                        value: format,
                        child: Text(format),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF4C1D95)),
              
              // Separate Files Option
              SwitchListTile(
                title: const Text(
                  'Create Separate Files',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                subtitle: const Text(
                  'Generate individual files for each date range and category',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                value: _separateFiles,
                onChanged: (value) {
                  setState(() {
                    _separateFiles = value;
                  });
                },
                activeColor: const Color(0xFF8B5CF6),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(color: Color(0xFF4C1D95)),
              
              // Naming Pattern
              Row(
                children: [
                  const Text(
                    'File Naming:',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _namingPattern,
                    dropdownColor: const Color(0xFF1E1B4B),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    underline: const SizedBox.shrink(),
                    onChanged: (value) {
                      setState(() {
                        _namingPattern = value!;
                      });
                    },
                    items: _namingPatterns.map((pattern) {
                      return DropdownMenuItem(
                        value: pattern,
                        child: SizedBox(
                          width: 40.w,
                          child: Text(
                            pattern,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Processing Status
        if (widget.isProcessing) ...[
          _buildProcessingStatus(),
          const SizedBox(height: 24),
        ],

        // Estimated Output
        _buildEstimatedOutput(),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _exportJobs.isNotEmpty ? _showScheduleDialog : null,
                icon: const Icon(Icons.schedule, size: 16),
                label: const Text('Schedule'),
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
                onPressed: _exportJobs.isNotEmpty && !widget.isProcessing
                    ? _startBatchExport
                    : null,
                icon: widget.isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow, size: 18),
                label: Text(widget.isProcessing ? 'Processing...' : 'Start Batch Export'),
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

  Widget _buildAddJobCard() {
    return GestureDetector(
      onTap: _showAddJobDialog,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF8B5CF6),
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Color(0xFF8B5CF6),
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Export Job',
                    style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Configure date range and categories for bulk export',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Color(0xFF8B5CF6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(int index, Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4C1D95)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['name'] ?? 'Export Job ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job['dateRange']} • ${(job['categories'] as List).length} categories',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _exportJobs.removeAt(index);
              });
            },
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C1D95)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sync,
                color: Color(0xFF8B5CF6),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Processing Export Jobs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(_processingProgress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _processingProgress,
            backgroundColor: const Color(0xFF4C1D95),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 8),
          Text(
            _currentProcessingJob.isNotEmpty 
              ? 'Processing: $_currentProcessingJob'
              : 'Preparing export jobs...',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedOutput() {
    int totalFiles = _exportJobs.length;
    if (_separateFiles) {
      totalFiles = _exportJobs.fold(0, (sum, job) => 
        sum + (job['categories'] as List).length);
    }

    double estimatedSize = totalFiles * 2.5; // 2.5MB per file average

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C1D95)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.assessment,
                color: Color(0xFF10B981),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Estimated Output',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEstimateStat('Files', '$totalFiles'),
              ),
              Expanded(
                child: _buildEstimateStat('Size', '~${estimatedSize.round()}MB'),
              ),
              Expanded(
                child: _buildEstimateStat('Time', '~${(totalFiles * 0.5).round()}min'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showAddJobDialog() {
    String jobName = '';
    DateTimeRange? dateRange;
    List<String> selectedCategories = [];
    
    final categories = ['Dreams', 'Sleep Quality', 'Mood Patterns', 'Lucid Dreams', 'Nightmares'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: BoxConstraints(maxHeight: 70.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Export Job',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Job Name
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Job Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF312E81),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => jobName = value,
                ),
                const SizedBox(height: 16),
                
                // Date Range
                GestureDetector(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => dateRange = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF312E81),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, color: Colors.white70),
                        const SizedBox(width: 12),
                        Text(
                          dateRange != null 
                            ? '${dateRange!.start.day}/${dateRange!.start.month} - ${dateRange!.end.day}/${dateRange!.end.month}'
                            : 'Select date range',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Categories
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categories:',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: categories.map((category) {
                    final isSelected = selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedCategories.add(category);
                          } else {
                            selectedCategories.remove(category);
                          }
                        });
                      },
                      backgroundColor: const Color(0xFF312E81),
                      selectedColor: const Color(0xFF8B5CF6),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                // Action Buttons
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
                        onPressed: dateRange != null && selectedCategories.isNotEmpty
                          ? () {
                              this.setState(() {
                                _exportJobs.add({
                                  'name': jobName.isNotEmpty ? jobName : 'Export Job ${_exportJobs.length + 1}',
                                  'dateRange': '${dateRange!.start.day}/${dateRange!.start.month} - ${dateRange!.end.day}/${dateRange!.end.month}',
                                  'categories': selectedCategories,
                                  'format': _selectedFormat,
                                });
                              });
                              Navigator.pop(context);
                            }
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add Job'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                color: Color(0xFF8B5CF6),
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Schedule Export',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Scheduled exports will be available in a future update. For now, you can start the batch export immediately.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startBatchExport() {
    final config = {
      'jobs': _exportJobs,
      'format': _selectedFormat,
      'separateFiles': _separateFiles,
      'namingPattern': _namingPattern,
    };

    widget.onBatchExportTap(config);
  }
}
import 'package:flutter/material.dart';


class InteractiveDrillDownWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final Function(Map<String, dynamic>) onDataPointTap;

  const InteractiveDrillDownWidget({
    super.key,
    required this.data,
    required this.title,
    required this.onDataPointTap,
  });

  @override
  State<InteractiveDrillDownWidget> createState() =>
      _InteractiveDrillDownWidgetState();
}

class _InteractiveDrillDownWidgetState extends State<InteractiveDrillDownWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.withAlpha(77)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Interactive',
                    style: TextStyle(color: Colors.blue, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Interactive Data Points
            ...List.generate(widget.data.length, (index) {
              final dataPoint = widget.data[index];
              return _buildDataPointCard(dataPoint, index);
            }),

            const SizedBox(height: 16),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tap any data point for detailed breakdown and related dream entries',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataPointCard(Map<String, dynamic> dataPoint, int index) {
    final isSelected = _selectedIndex == index;
    final confidence = dataPoint['confidence'] ?? 0;
    final value = dataPoint['value'] ?? 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
        widget.onDataPointTap(dataPoint);

        // Add haptic feedback
        // HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.withAlpha(51)
              : Colors.grey.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.withAlpha(77),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.purple.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Data Point Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getColorForConfidence(confidence).withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getIconForDataPoint(dataPoint['label'] ?? ''),
                    color: _getColorForConfidence(confidence),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Data Point Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dataPoint['label'] ?? 'Unknown',
                        style: TextStyle(
                          color: isSelected ? Colors.purple : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Value: ${_formatValue(value)}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Confidence Indicator
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getColorForConfidence(confidence).withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${confidence}%',
                        style: TextStyle(
                          color: _getColorForConfidence(confidence),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      isSelected ? Icons.expand_less : Icons.expand_more,
                      color: isSelected ? Colors.purple : Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),

            // Expanded Details
            if (isSelected) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(77),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights, color: Colors.purple, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Detailed Analysis',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Analysis Details
                    _buildAnalysisRow(
                        'Trend Direction', _getTrendDirection(value)),
                    _buildAnalysisRow('Statistical Significance',
                        _getSignificance(confidence)),
                    _buildAnalysisRow('Related Dreams', '${3 + index} entries'),
                    _buildAnalysisRow('Time Period', _getTimePeriod(index)),

                    const SizedBox(height: 12),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showRelatedDreams(dataPoint),
                            icon: Icon(Icons.list, size: 16),
                            label: const Text('View Dreams'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withAlpha(51),
                              foregroundColor: Colors.blue,
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _exportDataPoint(dataPoint),
                            icon: Icon(Icons.download, size: 16),
                            label: const Text('Export Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.withAlpha(51),
                              foregroundColor: Colors.green,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForConfidence(int confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getIconForDataPoint(String label) {
    if (label.toLowerCase().contains('dream')) return Icons.bedtime;
    if (label.toLowerCase().contains('emotion')) return Icons.favorite;
    if (label.toLowerCase().contains('pattern')) return Icons.pattern;
    if (label.toLowerCase().contains('frequency')) return Icons.bar_chart;
    return Icons.analytics;
  }

  String _formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    }
    return value.toString();
  }

  String _getTrendDirection(dynamic value) {
    // Simulate trend analysis
    final numValue = value is num ? value : 0;
    if (numValue > 50) return 'Increasing ↗️';
    if (numValue > 20) return 'Stable →';
    return 'Decreasing ↘️';
  }

  String _getSignificance(int confidence) {
    if (confidence >= 90) return 'Very High';
    if (confidence >= 70) return 'High';
    if (confidence >= 50) return 'Moderate';
    return 'Low';
  }

  String _getTimePeriod(int index) {
    final periods = ['Last 7 days', 'Last 30 days', 'Last 3 months'];
    return periods[index % periods.length];
  }

  void _showRelatedDreams(Map<String, dynamic> dataPoint) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Related Dreams: ${dataPoint['label']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Mock related dreams list
              ...List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bedtime, color: Colors.purple, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dream Entry ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '2 days ago • Rating: ${4 + index}/5',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportDataPoint(Map<String, dynamic> dataPoint) {
    // Simulate data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting data for: ${dataPoint['label']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

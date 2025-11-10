import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class DreamFrequencyTrendsWidget extends StatefulWidget {
  final String timeRange;
  final List<String> selectedTags;

  const DreamFrequencyTrendsWidget({
    super.key,
    required this.timeRange,
    required this.selectedTags,
  });

  @override
  State<DreamFrequencyTrendsWidget> createState() =>
      _DreamFrequencyTrendsWidgetState();
}

class _DreamFrequencyTrendsWidgetState extends State<DreamFrequencyTrendsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedView = 'Daily';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dream Frequency Trends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.timeRange,
                    style: const TextStyle(color: Colors.purple, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // View Selector
            Row(
              children: ['Daily', 'Weekly', 'Monthly'].map((view) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedView = view;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedView == view
                          ? Colors.purple
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedView == view
                            ? Colors.purple
                            : Colors.grey.withAlpha(77),
                      ),
                    ),
                    child: Text(
                      view,
                      style: TextStyle(
                        color:
                            _selectedView == view ? Colors.white : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Line Chart
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withAlpha(51),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = _getXAxisLabels();
                          if (value.toInt() < labels.length) {
                            return Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getDataPoints(),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.purple,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.withAlpha(51),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Average', '3.2', 'dreams/day'),
                _buildStatCard('Peak Day', 'Monday', '4.8 avg'),
                _buildStatCard('Consistency', '87%', 'score'),
              ],
            ),
            const SizedBox(height: 16),

            // Seasonal Analysis
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seasonal Analysis',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your dream frequency increases by 23% during winter months, with peak activity in December.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Improving trend detected',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  List<String> _getXAxisLabels() {
    switch (_selectedView) {
      case 'Daily':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'Weekly':
        return ['W1', 'W2', 'W3', 'W4'];
      case 'Monthly':
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
      default:
        return [];
    }
  }

  List<FlSpot> _getDataPoints() {
    switch (_selectedView) {
      case 'Daily':
        return [
          const FlSpot(0, 2.5),
          const FlSpot(1, 3.2),
          const FlSpot(2, 2.8),
          const FlSpot(3, 4.1),
          const FlSpot(4, 3.6),
          const FlSpot(5, 4.8),
          const FlSpot(6, 3.9),
        ];
      case 'Weekly':
        return [
          const FlSpot(0, 22),
          const FlSpot(1, 25),
          const FlSpot(2, 28),
          const FlSpot(3, 26),
        ];
      case 'Monthly':
        return [
          const FlSpot(0, 89),
          const FlSpot(1, 76),
          const FlSpot(2, 95),
          const FlSpot(3, 102),
          const FlSpot(4, 87),
          const FlSpot(5, 110),
        ];
      default:
        return [];
    }
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class EmotionalPatternTrackingWidget extends StatefulWidget {
  final List<String> selectedEmotions;
  final String timeRange;

  const EmotionalPatternTrackingWidget({
    super.key,
    required this.selectedEmotions,
    required this.timeRange,
  });

  @override
  State<EmotionalPatternTrackingWidget> createState() =>
      _EmotionalPatternTrackingWidgetState();
}

class _EmotionalPatternTrackingWidgetState
    extends State<EmotionalPatternTrackingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _selectedVisualization = 'heatmap';

  final Map<String, Color> _emotionColors = {
    'Joy': Colors.yellow,
    'Sadness': Colors.blue,
    'Anger': Colors.red,
    'Fear': Colors.purple,
    'Surprise': Colors.orange,
    'Disgust': Colors.green,
    'Love': Colors.pink,
    'Excitement': Colors.cyan,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Emotional Pattern Tracking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.bar_chart, color: Colors.purple),
                  onSelected: (value) {
                    setState(() {
                      _selectedVisualization = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'heatmap',
                      child: Text('Heat Map'),
                    ),
                    const PopupMenuItem(
                      value: 'sentiment',
                      child: Text('Sentiment Graph'),
                    ),
                    const PopupMenuItem(
                      value: 'trajectory',
                      child: Text('Trajectory Timeline'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Visualization Content
            if (_selectedVisualization == 'heatmap') ...[
              _buildEmotionalHeatMap(),
            ] else if (_selectedVisualization == 'sentiment') ...[
              _buildSentimentAnalysisGraph(),
            ] else ...[
              _buildEmotionalTrajectoryTimeline(),
            ],

            const SizedBox(height: 20),

            // Mood Correlations
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
                    'Mood Correlations',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCorrelationItem('Sleep Quality', 0.78, Colors.green),
                  _buildCorrelationItem('Dream Vividness', 0.65, Colors.blue),
                  _buildCorrelationItem('Recall Accuracy', 0.43, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Predictive Trend Indicators
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Predictive Trend Indicators',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Based on your recent patterns, you\'re likely to experience:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildPredictionItem(
                      'Increased joy dreams', '73%', Colors.yellow),
                  _buildPredictionItem('Adventure themes', '58%', Colors.cyan),
                  _buildPredictionItem('Lucid dreaming', '42%', Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalHeatMap() {
    return Column(
      children: [
        const Text(
          'Emotional Intensity Heat Map',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 28, // 4 weeks
            itemBuilder: (context, index) {
              final intensity = (index % 5) / 4.0; // Mock intensity
              return Container(
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(intensity),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: intensity > 0.5 ? Colors.white : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Low',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            Row(
              children: List.generate(5, (index) {
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity((index + 1) / 5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const Text('High',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildSentimentAnalysisGraph() {
    return Column(
      children: [
        const Text(
          'Sentiment Analysis Over Time',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 16),
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
                      final labels = ['Negative', 'Neutral', 'Positive'];
                      if (value.toInt() < labels.length) {
                        return Text(
                          labels[value.toInt()],
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 60,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];
                      if (value.toInt() < days.length) {
                        return Text(
                          days[value.toInt()],
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 1.2),
                    FlSpot(1, 1.8),
                    FlSpot(2, 1.5),
                    FlSpot(3, 2.1),
                    FlSpot(4, 1.9),
                    FlSpot(5, 2.3),
                    FlSpot(6, 2.0),
                  ],
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalTrajectoryTimeline() {
    return Column(
      children: [
        const Text(
          'Emotional Trajectory Timeline',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final emotions = _emotionColors.keys.toList();
              final emotion = emotions[index % emotions.length];
              final color = _emotionColors[emotion]!;

              return Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      width: 60,
                      decoration: BoxDecoration(
                        color: color.withAlpha(77),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getEmotionIcon(emotion),
                            color: color,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${60 + (index * 5)}%',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      emotion,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'Day ${index + 1}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationItem(String factor, double correlation, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            factor,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Row(
            children: [
              Container(
                width: 100,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(77),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: correlation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                correlation.toStringAsFixed(2),
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(
      String prediction, String probability, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              prediction,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              probability,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion) {
      case 'Joy':
        return Icons.sentiment_very_satisfied;
      case 'Sadness':
        return Icons.sentiment_very_dissatisfied;
      case 'Anger':
        return Icons.local_fire_department;
      case 'Fear':
        return Icons.psychology_alt;
      case 'Surprise':
        return Icons.lightbulb;
      case 'Love':
        return Icons.favorite;
      case 'Excitement':
        return Icons.star;
      default:
        return Icons.sentiment_neutral;
    }
  }
}

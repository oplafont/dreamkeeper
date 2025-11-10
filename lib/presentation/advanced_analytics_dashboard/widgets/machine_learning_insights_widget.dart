import 'package:flutter/material.dart';


class MachineLearningInsightsWidget extends StatefulWidget {
  final String analysisType;
  final Map<String, dynamic> filters;

  const MachineLearningInsightsWidget({
    super.key,
    required this.analysisType,
    required this.filters,
  });

  @override
  State<MachineLearningInsightsWidget> createState() =>
      _MachineLearningInsightsWidgetState();
}

class _MachineLearningInsightsWidgetState
    extends State<MachineLearningInsightsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _startAnalysis();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnalysis() {
    setState(() {
      _isAnalyzing = true;
    });
    _animationController.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        _animationController.stop();
        _animationController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withAlpha(51),
            Colors.indigo.withAlpha(51),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _isAnalyzing
                    ? _pulseAnimation
                    : AlwaysStoppedAnimation(1.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI-Powered Insights',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getAnalysisDescription(),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isAnalyzing
                      ? Colors.orange.withAlpha(51)
                      : Colors.green.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isAnalyzing ? 'Analyzing...' : 'Complete',
                  style: TextStyle(
                    color: _isAnalyzing ? Colors.orange : Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isAnalyzing) ...[
            _buildAnalyzingState(),
          ] else ...[
            _buildInsightsContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Column(
      children: [
        LinearProgressIndicator(
          backgroundColor: Colors.grey.withAlpha(77),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Neural networks processing your dream patterns...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Processing Steps
        ...List.generate(3, (index) {
          final steps = [
            'Analyzing narrative patterns',
            'Cross-referencing psychological indicators',
            'Generating personalized insights',
          ];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.radio_button_checked,
                  color: Colors.deepPurple.withAlpha(179),
                  size: 12,
                ),
                const SizedBox(width: 8),
                Text(
                  steps[index],
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInsightsContent() {
    final insights = _getInsightsForAnalysisType();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Model Performance Metrics
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(77),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Accuracy', '94.2%', Colors.green),
              _buildMetric('Confidence', '87.5%', Colors.blue),
              _buildMetric('Processing', '2.3s', Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // AI Insights
        const Text(
          'Key Insights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...List.generate(insights.length, (index) {
          final insight = insights[index];
          return _buildInsightCard(insight, index);
        }),

        const SizedBox(height: 16),

        // Continuous Learning Status
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withAlpha(77)),
          ),
          child: Row(
            children: [
              Icon(Icons.refresh, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Continuous Learning Active',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Model improves accuracy based on your feedback and behavioral data',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Online',
                  style: TextStyle(color: Colors.green, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight['color'].withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insight['color'].withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(insight['icon'], color: insight['color'], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight['title'],
                  style: TextStyle(
                    color: insight['color'],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: insight['color'].withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${insight['confidence']}%',
                  style: TextStyle(
                    color: insight['color'],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight['description'],
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: insight['color'], size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  insight['recommendation'],
                  style: TextStyle(
                    color: insight['color'],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getAnalysisDescription() {
    switch (widget.analysisType) {
      case 'theme_identification':
        return 'Deep learning models analyzing subconscious patterns';
      case 'progress_tracking':
        return 'Predictive analytics for personal development';
      default:
        return 'Advanced pattern recognition and behavioral analysis';
    }
  }

  List<Map<String, dynamic>> _getInsightsForAnalysisType() {
    switch (widget.analysisType) {
      case 'theme_identification':
        return [
          {
            'icon': Icons.psychology_alt,
            'title': 'Recurring Archetype Detected',
            'description':
                'Your dreams show strong "Hero\'s Journey" narrative patterns, suggesting personal growth phase.',
            'recommendation':
                'Consider journaling about challenges you\'re currently facing in waking life.',
            'confidence': 89,
            'color': Colors.purple,
          },
          {
            'icon': Icons.trending_up,
            'title': 'Symbolic Evolution',
            'description':
                'Water symbols have increased 40% this month, often indicating emotional processing.',
            'recommendation':
                'Practice mindfulness meditation to support emotional integration.',
            'confidence': 76,
            'color': Colors.blue,
          },
        ];
      case 'progress_tracking':
        return [
          {
            'icon': Icons.emoji_events,
            'title': 'Breakthrough Prediction',
            'description':
                'Based on current patterns, 78% likelihood of achieving lucid dreaming within 2 weeks.',
            'recommendation':
                'Maintain current reality check practices and increase dream journaling frequency.',
            'confidence': 78,
            'color': Colors.green,
          },
          {
            'icon': Icons.warning,
            'title': 'Sleep Quality Correlation',
            'description':
                'Dream recall drops 23% when sleep quality is below 7/10. Strong statistical significance.',
            'recommendation':
                'Focus on sleep hygiene improvements for better dream retention.',
            'confidence': 94,
            'color': Colors.orange,
          },
        ];
      default:
        return [
          {
            'icon': Icons.insights,
            'title': 'Pattern Recognition',
            'description':
                'Multiple behavioral patterns identified with high confidence scores.',
            'recommendation': 'Continue current practices for optimal results.',
            'confidence': 85,
            'color': Colors.indigo,
          },
        ];
    }
  }
}

import 'package:flutter/material.dart';

class SubconsciousThemeIdentificationWidget extends StatefulWidget {
  final List<String> selectedTags;
  final String timeRange;

  const SubconsciousThemeIdentificationWidget({
    super.key,
    required this.selectedTags,
    required this.timeRange,
  });

  @override
  State<SubconsciousThemeIdentificationWidget> createState() =>
      _SubconsciousThemeIdentificationWidgetState();
}

class _SubconsciousThemeIdentificationWidgetState
    extends State<SubconsciousThemeIdentificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<Map<String, dynamic>> _identifiedThemes = [
    {
      'theme': 'Flying & Freedom',
      'confidence': 92,
      'frequency': 15,
      'description':
          'Dreams involving flight often represent desire for freedom and escape from limitations',
      'symbols': ['Birds', 'Wings', 'Heights', 'Clouds'],
      'psychological_meaning':
          'Liberation from constraints, spiritual ascension',
      'color': Colors.blue,
      'trend': 'increasing',
    },
    {
      'theme': 'Water & Emotions',
      'confidence': 87,
      'frequency': 12,
      'description':
          'Water-related themes correlate with emotional states and subconscious feelings',
      'symbols': ['Ocean', 'Rain', 'Rivers', 'Swimming'],
      'psychological_meaning': 'Emotional processing, cleansing, renewal',
      'color': Colors.cyan,
      'trend': 'stable',
    },
    {
      'theme': 'Chase & Avoidance',
      'confidence': 78,
      'frequency': 8,
      'description':
          'Being chased represents avoiding confrontation with unresolved issues',
      'symbols': ['Running', 'Hiding', 'Darkness', 'Pursuit'],
      'psychological_meaning': 'Avoidance patterns, unresolved conflicts',
      'color': Colors.red,
      'trend': 'decreasing',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuad),
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
    return SlideTransition(
      position: _slideAnimation.drive(Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      )),
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
                  'Subconscious Theme Identification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'AI-Powered',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Natural Language Processing Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withAlpha(77)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NLP Analysis Complete',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_identifiedThemes.length} recurring themes identified from ${widget.timeRange.toLowerCase()}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '94% Accuracy',
                      style: TextStyle(color: Colors.green, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Theme Cards
            ...List.generate(_identifiedThemes.length, (index) {
              final theme = _identifiedThemes[index];
              return _buildThemeCard(theme, index);
            }),

            const SizedBox(height: 16),

            // Pattern Recognition Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.purple, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Pattern Recognition Summary',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem('Total Symbols Analyzed', '147'),
                  _buildSummaryItem('Narrative Patterns Detected', '23'),
                  _buildSummaryItem('Psychological Themes', '8'),
                  _buildSummaryItem('Cross-Reference Accuracy', '91%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(Map<String, dynamic> theme, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme['color'].withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme['color'].withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  theme['theme'],
                  style: TextStyle(
                    color: theme['color'],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    theme['trend'] == 'increasing'
                        ? Icons.trending_up
                        : theme['trend'] == 'decreasing'
                            ? Icons.trending_down
                            : Icons.trending_flat,
                    color: theme['trend'] == 'increasing'
                        ? Colors.green
                        : theme['trend'] == 'decreasing'
                            ? Colors.red
                            : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme['color'].withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${theme['confidence']}%',
                      style: TextStyle(
                        color: theme['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            theme['description'],
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // Symbols
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (theme['symbols'] as List<String>).map((symbol) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  symbol,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Psychological Meaning
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(77),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Psychological Interpretation:',
                  style: TextStyle(
                    color: theme['color'],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  theme['psychological_meaning'],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Frequency and Educational Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frequency: ${theme['frequency']} occurrences',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              GestureDetector(
                onTap: () => _showEducationalInfo(theme),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: theme['color'], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Learn More',
                      style: TextStyle(
                        color: theme['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.purple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showEducationalInfo(Map<String, dynamic> theme) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(theme['color'], color: theme['color'], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      theme['theme'],
                      style: TextStyle(
                        color: theme['color'],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Educational Context:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This theme appears in ${theme['frequency']} of your dreams with ${theme['confidence']}% confidence. '
                'Research shows that ${theme['theme'].toLowerCase()} themes often indicate ${theme['psychological_meaning'].toLowerCase()}. '
                'Consider reflecting on areas of your life where you might be experiencing similar patterns.',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reflection Questions:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• What situations in your waking life might relate to this theme?\n'
                '• How do you feel when experiencing these dreams?\n'
                '• Are there patterns in when these dreams occur?',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme['color'],
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
}
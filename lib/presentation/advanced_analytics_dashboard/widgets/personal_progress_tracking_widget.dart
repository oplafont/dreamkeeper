import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class PersonalProgressTrackingWidget extends StatefulWidget {
  final String timeRange;
  final String sleepQuality;

  const PersonalProgressTrackingWidget({
    super.key,
    required this.timeRange,
    required this.sleepQuality,
  });

  @override
  State<PersonalProgressTrackingWidget> createState() =>
      _PersonalProgressTrackingWidgetState();
}

class _PersonalProgressTrackingWidgetState
    extends State<PersonalProgressTrackingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.bounceOut),
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
      scale: _bounceAnimation,
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
                  'Personal Progress Tracking',
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
                      Icon(Icons.trending_up, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Improving',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Gamified Progress Indicators
            _buildGameProgressSection(),
            const SizedBox(height: 20),

            // Journaling Consistency Metrics
            _buildConsistencyMetrics(),
            const SizedBox(height: 20),

            // Dream Recall Improvement
            _buildRecallImprovement(),
            const SizedBox(height: 20),

            // Therapeutic Milestones
            _buildTherapeuticMilestones(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withAlpha(51), Colors.blue.withAlpha(51)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Achievement Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dream Keeper Level 7',
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              const Text(
                '2,340 / 3,000 XP',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 2340 / 3000,
            backgroundColor: Colors.grey.withAlpha(77),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          const SizedBox(height: 16),

          // Achievements Grid
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildAchievementBadge('🌟', 'Dream Streak', '15 days', true),
              _buildAchievementBadge('📝', 'Detail Master', 'Level 3', true),
              _buildAchievementBadge('🎯', 'Lucid Dreams', '5 achieved', true),
              _buildAchievementBadge('🔍', 'Pattern Hunter', '2/3', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(
      String emoji, String title, String progress, bool achieved) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            achieved ? Colors.amber.withAlpha(51) : Colors.grey.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: achieved ? Colors.amber : Colors.grey.withAlpha(77),
          width: achieved ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: achieved ? Colors.amber : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            progress,
            style: TextStyle(
              color: achieved ? Colors.white70 : Colors.grey,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Journaling Consistency',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricCard('Current Streak', '15', 'days', Colors.green),
              _buildMetricCard('Weekly Average', '5.2', 'entries', Colors.blue),
              _buildMetricCard(
                  'Best Month', 'Oct 2024', '28 entries', Colors.purple),
            ],
          ),
          const SizedBox(height: 16),

          // Consistency Chart
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 7,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
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
                        return Text(
                          days[value.toInt() % days.length],
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  final values = [5, 6, 4, 7, 6, 3, 5];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[index].toDouble(),
                        color: Colors.blue,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecallImprovement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.memory, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Dream Recall Improvement',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recall Rate Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Recall Rate',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Text(
                '78% (+12% this month)',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.78,
            backgroundColor: Colors.grey.withAlpha(77),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 16),

          // Improvement Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimelineItem('Week 1', '45%', false),
              _buildTimelineItem('Week 2', '58%', false),
              _buildTimelineItem('Week 3', '67%', false),
              _buildTimelineItem('Week 4', '78%', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTherapeuticMilestones() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Therapeutic Milestones',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMilestoneItem(
            'Nightmare Frequency Reduction',
            'Decreased by 40% over 3 months',
            true,
            Colors.green,
          ),
          _buildMilestoneItem(
            'Emotional Regulation',
            'Improved stress response patterns',
            true,
            Colors.blue,
          ),
          _buildMilestoneItem(
            'Lucid Dreaming Mastery',
            'Progress: 3 out of 5 goals achieved',
            false,
            Colors.orange,
          ),
          _buildMilestoneItem(
            'Sleep Quality Enhancement',
            'Target: 85% (Current: 78%)',
            false,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String week, String percentage, bool isCurrent) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isCurrent ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? Colors.green : Colors.grey,
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          week,
          style: TextStyle(
            color: isCurrent ? Colors.green : Colors.grey,
            fontSize: 10,
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            color: isCurrent ? Colors.green : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneItem(
      String title, String description, bool achieved, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            achieved ? Icons.check_circle : Icons.radio_button_unchecked,
            color: achieved ? Colors.green : color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: achieved ? Colors.green : Colors.white,
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
          if (achieved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Completed',
                style: TextStyle(color: Colors.green, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}

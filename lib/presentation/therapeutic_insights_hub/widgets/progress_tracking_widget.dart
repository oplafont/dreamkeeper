import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';


class ProgressTrackingWidget extends StatelessWidget {
  final Map<String, dynamic> progressData;

  const ProgressTrackingWidget({
    super.key,
    required this.progressData,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyProgress =
        progressData['weeklyProgress'] as Map<String, dynamic>? ?? {};
    final improvementAreas =
        progressData['improvementAreas'] as List<String>? ?? [];
    final overallTrend = progressData['overallTrend'] as String? ?? 'stable';

    if (weeklyProgress.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverallTrendCard(overallTrend),
        SizedBox(height: 3.h),
        _buildWeeklyProgressChart(weeklyProgress),
        SizedBox(height: 3.h),
        _buildImprovementAreas(improvementAreas),
        SizedBox(height: 3.h),
        _buildWellnessMetrics(weeklyProgress),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Icon(
              Icons.trending_up,
              color: Colors.white38,
              size: 48.sp,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Progress Data Available',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Continue tracking your dreams to see wellness progress over time',
              style: GoogleFonts.inter(
                color: Colors.white38,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallTrendCard(String trend) {
    final trendData = _getTrendData(trend);

    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: trendData['color'].withAlpha(26),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                trendData['icon'],
                color: trendData['color'],
                size: 30,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Wellness Trend',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    trendData['title'],
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    trendData['description'],
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11.sp,
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

  Widget _buildWeeklyProgressChart(Map<String, dynamic> weeklyProgress) {
    final chartData = <FlSpot>[];
    final weeks = weeklyProgress.keys.toList()..sort();

    for (int i = 0; i < weeks.length; i++) {
      final weekData = weeklyProgress[weeks[i]] as Map<String, dynamic>;
      final avgQuality = weekData['avgQuality'] as double? ?? 0.0;
      chartData.add(FlSpot(i.toDouble(), avgQuality));
    }

    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Sleep Quality Trend',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white10,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final weekIndex = value.toInt();
                          if (weekIndex < weeks.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                'W${weekIndex + 1}',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 10.sp,
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 10.sp,
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.white10),
                  ),
                  minX: 0,
                  maxX: (weeks.length - 1).toDouble(),
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withAlpha(204),
                          const Color(0xFF8B5CF6).withAlpha(77),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF8B5CF6),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B5CF6).withAlpha(77),
                            const Color(0xFF8B5CF6).withAlpha(26),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementAreas(List<String> improvementAreas) {
    if (improvementAreas.isEmpty) {
      return Card(
        color: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(26),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Excellent Progress!',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'No major improvement areas identified',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12.sp,
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

    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Areas for Improvement',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ...improvementAreas
                .map((area) => _buildImprovementAreaCard(area))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementAreaCard(String area) {
    final areaData = _getImprovementAreaData(area);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: areaData['color'].withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: areaData['color'].withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              areaData['icon'],
              color: areaData['color'],
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  areaData['suggestion'],
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white38,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessMetrics(Map<String, dynamic> weeklyProgress) {
    final totalDreams = weeklyProgress.values
        .map(
            (week) => (week as Map<String, dynamic>)['dreamCount'] as int? ?? 0)
        .reduce((a, b) => a + b);

    final avgQuality = weeklyProgress.values
            .map((week) =>
                (week as Map<String, dynamic>)['avgQuality'] as double? ?? 0.0)
            .reduce((a, b) => a + b) /
        weeklyProgress.length;

    return Card(
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wellness Metrics (30 Days)',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Dream Entries',
                    totalDreams.toString(),
                    Icons.book,
                    const Color(0xFF8B5CF6),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildMetricCard(
                    'Avg Quality',
                    avgQuality.toStringAsFixed(1),
                    Icons.star,
                    const Color(0xFFFBBF24),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Active Weeks',
                    weeklyProgress.length.toString(),
                    Icons.calendar_today,
                    const Color(0xFF10B981),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildMetricCard(
                    'Progress Score',
                    _calculateProgressScore(weeklyProgress).toString(),
                    Icons.trending_up,
                    const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getTrendData(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return {
          'title': 'Improving Trend',
          'description':
              'Your wellness indicators are getting better over time',
          'icon': Icons.trending_up,
          'color': const Color(0xFF10B981),
        };
      case 'declining':
        return {
          'title': 'Needs Attention',
          'description': 'Some wellness indicators could use improvement',
          'icon': Icons.trending_down,
          'color': const Color(0xFFEF4444),
        };
      default:
        return {
          'title': 'Stable Progress',
          'description':
              'Your wellness indicators are maintaining steady levels',
          'icon': Icons.trending_flat,
          'color': const Color(0xFF8B5CF6),
        };
    }
  }

  Map<String, dynamic> _getImprovementAreaData(String area) {
    switch (area.toLowerCase()) {
      case 'sleep quality':
        return {
          'icon': Icons.bedtime,
          'color': const Color(0xFF3B82F6),
          'suggestion': 'Focus on sleep hygiene and bedtime routines',
        };
      case 'emotional regulation':
        return {
          'icon': Icons.psychology,
          'color': const Color(0xFF8B5CF6),
          'suggestion':
              'Practice mindfulness and emotional awareness techniques',
        };
      case 'dream recall':
        return {
          'icon': Icons.memory,
          'color': const Color(0xFFFBBF24),
          'suggestion': 'Keep a dream journal and improve recall techniques',
        };
      default:
        return {
          'icon': Icons.lightbulb,
          'color': const Color(0xFF10B981),
          'suggestion': 'Focus on this area for better overall wellness',
        };
    }
  }

  int _calculateProgressScore(Map<String, dynamic> weeklyProgress) {
    if (weeklyProgress.isEmpty) return 0;

    double totalScore = 0;
    int weekCount = 0;

    weeklyProgress.values.forEach((week) {
      final weekData = week as Map<String, dynamic>;
      final dreamCount = weekData['dreamCount'] as int? ?? 0;
      final avgQuality = weekData['avgQuality'] as double? ?? 0.0;

      // Score based on consistency and quality
      final consistencyScore = (dreamCount >= 3 ? 50 : dreamCount * 16.7);
      final qualityScore = (avgQuality / 5) * 50;

      totalScore += consistencyScore + qualityScore;
      weekCount++;
    });

    return (totalScore / weekCount).round();
  }
}

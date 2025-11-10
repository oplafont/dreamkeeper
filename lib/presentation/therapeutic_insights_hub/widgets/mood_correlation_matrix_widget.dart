import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodCorrelationMatrixWidget extends StatelessWidget {
  final Map<String, dynamic> moodData;

  const MoodCorrelationMatrixWidget({
    super.key,
    required this.moodData,
  });

  @override
  Widget build(BuildContext context) {
    final moodCounts = moodData['moodCounts'] as Map<String, int>? ?? {};
    final emotionCorrelations =
        moodData['emotionCorrelations'] as Map<String, List<String>>? ?? {};
    final totalEntries = moodData['totalEntries'] as int? ?? 0;

    if (moodCounts.isEmpty) {
      return _buildEmptyState();
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
              'Mood Correlation Matrix',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Analyzing relationships between dream themes and emotional states',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 3.h),
            _buildMoodDistributionChart(moodCounts, totalEntries),
            SizedBox(height: 3.h),
            _buildHeatMap(emotionCorrelations),
            SizedBox(height: 3.h),
            _buildTrendAnalysis(moodCounts),
          ],
        ),
      ),
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
              Icons.mood_outlined,
              color: Colors.white38,
              size: 48.sp,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Mood Data Available',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Record more dreams with mood tracking to see correlations',
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

  Widget _buildMoodDistributionChart(
      Map<String, int> moodCounts, int totalEntries) {
    final pieChartData = moodCounts.entries.map((entry) {
      final percentage = (entry.value / totalEntries * 100);
      return PieChartSectionData(
        color: _getMoodColor(entry.key),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Distribution',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: pieChartData,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: moodCounts.entries
                    .map((entry) => Padding(
                          padding: EdgeInsets.only(bottom: 1.h),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getMoodColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  '${entry.key.toUpperCase()} (${entry.value})',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeatMap(Map<String, List<String>> emotionCorrelations) {
    final allEmotions = <String>{};
    emotionCorrelations.values.forEach((emotions) {
      allEmotions.addAll(emotions);
    });

    if (allEmotions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No emotional theme correlations found in recent dreams',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12.sp,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emotion-Mood Heat Map',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              children: allEmotions
                  .take(5)
                  .map((emotion) => Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                              child: Text(
                                emotion.toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ...emotionCorrelations.keys.map((mood) {
                              final hasCorrelation = emotionCorrelations[mood]
                                      ?.contains(emotion) ??
                                  false;
                              return Container(
                                margin: EdgeInsets.only(right: 1.w),
                                width: 8.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: hasCorrelation
                                      ? _getMoodColor(mood).withAlpha(204)
                                      : Colors.grey.withAlpha(26),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendAnalysis(Map<String, int> moodCounts) {
    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trend Analysis',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (sortedMoods.isNotEmpty) ...[
                _buildTrendItem(
                  'Most Common Mood',
                  sortedMoods.first.key,
                  '${sortedMoods.first.value} occurrences',
                  _getMoodColor(sortedMoods.first.key),
                  Icons.trending_up,
                ),
                SizedBox(height: 2.h),
              ],
              _buildTrendItem(
                'Emotional Variety',
                '${moodCounts.length} different moods',
                _getVarietyInsight(moodCounts.length),
                const Color(0xFF8B5CF6),
                Icons.psychology,
              ),
              SizedBox(height: 2.h),
              _buildTrendItem(
                'Pattern Strength',
                _getPatternStrength(sortedMoods),
                'Based on mood distribution',
                const Color(0xFF10B981),
                Icons.analytics,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(String title, String value, String description,
      Color color, IconData icon) {
    return Row(
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
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'excited':
        return const Color(0xFFFBBF24);
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return const Color(0xFF10B981);
      case 'anxious':
      case 'worried':
      case 'stressed':
        return const Color(0xFFF59E0B);
      case 'sad':
      case 'melancholy':
      case 'depressed':
        return const Color(0xFF3B82F6);
      case 'angry':
      case 'frustrated':
      case 'irritated':
        return const Color(0xFFEF4444);
      case 'fearful':
      case 'scared':
      case 'terrified':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getVarietyInsight(int varietyCount) {
    if (varietyCount <= 2) {
      return 'Low emotional range';
    } else if (varietyCount <= 4) {
      return 'Moderate emotional range';
    } else {
      return 'High emotional variety';
    }
  }

  String _getPatternStrength(List<MapEntry<String, int>> sortedMoods) {
    if (sortedMoods.isEmpty) return 'No patterns';

    final topMoodCount = sortedMoods.first.value;
    final totalMoods = sortedMoods.fold(0, (sum, entry) => sum + entry.value);
    final dominance = topMoodCount / totalMoods;

    if (dominance > 0.6) {
      return 'Strong pattern detected';
    } else if (dominance > 0.4) {
      return 'Moderate patterns';
    } else {
      return 'Varied patterns';
    }
  }
}

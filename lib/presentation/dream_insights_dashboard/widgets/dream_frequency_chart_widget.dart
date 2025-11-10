import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DreamFrequencyChartWidget extends StatelessWidget {
  final String timeRange;

  const DreamFrequencyChartWidget({Key? key, required this.timeRange})
    : super(key: key);

  List<FlSpot> _getFrequencyData() {
    switch (timeRange) {
      case 'Week':
        return [
          const FlSpot(0, 2),
          const FlSpot(1, 1),
          const FlSpot(2, 3),
          const FlSpot(3, 2),
          const FlSpot(4, 4),
          const FlSpot(5, 1),
          const FlSpot(6, 3),
        ];
      case 'Month':
        return [
          const FlSpot(0, 8),
          const FlSpot(1, 12),
          const FlSpot(2, 15),
          const FlSpot(3, 10),
        ];
      case 'Year':
        return [
          const FlSpot(0, 45),
          const FlSpot(1, 52),
          const FlSpot(2, 38),
          const FlSpot(3, 61),
          const FlSpot(4, 48),
          const FlSpot(5, 55),
          const FlSpot(6, 42),
          const FlSpot(7, 58),
          const FlSpot(8, 47),
          const FlSpot(9, 53),
          const FlSpot(10, 49),
          const FlSpot(11, 44),
        ];
      default:
        return [];
    }
  }

  List<String> _getBottomTitles() {
    switch (timeRange) {
      case 'Week':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'Month':
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      case 'Year':
        return [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getFrequencyData();
    final titles = _getBottomTitles();

    return Container(
      height: 25.h,
      padding: EdgeInsets.all(3.w),
      child: Semantics(
        label: "Dream frequency chart showing patterns over $timeRange",
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < titles.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          titles[index],
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(fontSize: 10.sp),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: timeRange == 'Year' ? 10 : 1,
                  reservedSize: 40,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        value.toInt().toString(),
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(fontSize: 10.sp),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            minX: 0,
            maxX: (spots.length - 1).toDouble(),
            minY: 0,
            maxY:
                spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 2,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lightTheme.colorScheme.secondary,
                    AppTheme.lightTheme.colorScheme.primary,
                  ],
                ),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.secondary.withValues(
                        alpha: 0.3,
                      ),
                      AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

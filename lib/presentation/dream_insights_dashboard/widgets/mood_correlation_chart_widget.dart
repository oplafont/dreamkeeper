import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MoodCorrelationChartWidget extends StatelessWidget {
  const MoodCorrelationChartWidget({Key? key}) : super(key: key);

  List<FlSpot> _getHappyMoodData() {
    return [
      const FlSpot(0, 3.5),
      const FlSpot(1, 4.2),
      const FlSpot(2, 3.8),
      const FlSpot(3, 4.5),
      const FlSpot(4, 4.1),
      const FlSpot(5, 3.9),
      const FlSpot(6, 4.3),
    ];
  }

  List<FlSpot> _getAnxiousMoodData() {
    return [
      const FlSpot(0, 2.1),
      const FlSpot(1, 1.8),
      const FlSpot(2, 2.5),
      const FlSpot(3, 1.5),
      const FlSpot(4, 2.2),
      const FlSpot(5, 2.8),
      const FlSpot(6, 1.9),
    ];
  }

  List<FlSpot> _getCalmMoodData() {
    return [
      const FlSpot(0, 4.1),
      const FlSpot(1, 3.8),
      const FlSpot(2, 4.4),
      const FlSpot(3, 4.0),
      const FlSpot(4, 4.2),
      const FlSpot(5, 3.7),
      const FlSpot(6, 4.1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.h,
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                'Happy',
                AppTheme.lightTheme.colorScheme.secondary,
              ),
              _buildLegendItem('Anxious', Colors.orange),
              _buildLegendItem('Calm', Colors.green),
            ],
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: Semantics(
              label:
                  "Mood correlation chart showing emotional patterns in dreams",
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
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
                          const titles = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
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
                        interval: 1,
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
                  maxX: 6,
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getHappyMoodData(),
                      isCurved: true,
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    ),
                    LineChartBarData(
                      spots: _getAnxiousMoodData(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: Colors.orange,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    ),
                    LineChartBarData(
                      spots: _getCalmMoodData(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: Colors.green,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DreamCategoryChartWidget extends StatefulWidget {
  const DreamCategoryChartWidget({Key? key}) : super(key: key);

  @override
  State<DreamCategoryChartWidget> createState() =>
      _DreamCategoryChartWidgetState();
}

class _DreamCategoryChartWidgetState extends State<DreamCategoryChartWidget> {
  int touchedIndex = -1;

  final List<Map<String, dynamic>> categoryData = [
    {
      'category': 'Adventure',
      'percentage': 28.5,
      'color': const Color(0xFF667EEA),
    },
    {
      'category': 'Nightmare',
      'percentage': 15.2,
      'color': const Color(0xFFE53E3E),
    },
    {
      'category': 'Flying',
      'percentage': 22.8,
      'color': const Color(0xFF48BB78),
    },
    {'category': 'Lucid', 'percentage': 18.7, 'color': const Color(0xFF805AD5)},
    {'category': 'Other', 'percentage': 14.8, 'color': const Color(0xFFED8936)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Semantics(
                    label: "Dream category distribution pie chart",
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (
                            FlTouchEvent event,
                            pieTouchResponse,
                          ) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 8.w,
                        sections: _buildPieChartSections(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        categoryData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          final isSelected = touchedIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                touchedIndex = isSelected ? -1 : index;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 0.5.h),
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? (data['color'] as Color).withValues(
                                          alpha: 0.1,
                                        )
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 3.w,
                                    height: 3.w,
                                    decoration: BoxDecoration(
                                      color: data['color'] as Color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['category'] as String,
                                          style: AppTheme
                                              .lightTheme
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                fontSize: 11.sp,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${(data['percentage'] as double).toStringAsFixed(1)}%',
                                          style: AppTheme
                                              .lightTheme
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color:
                                                    AppTheme
                                                        .lightTheme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                fontSize: 10.sp,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    return categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 14.sp : 12.sp;
      final radius = isTouched ? 12.w : 10.w;

      return PieChartSectionData(
        color: data['color'] as Color,
        value: data['percentage'] as double,
        title:
            isTouched
                ? '${(data['percentage'] as double).toStringAsFixed(1)}%'
                : '',
        radius: radius,
        titleStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

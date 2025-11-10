import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WordCloudWidget extends StatefulWidget {
  const WordCloudWidget({Key? key}) : super(key: key);

  @override
  State<WordCloudWidget> createState() => _WordCloudWidgetState();
}

class _WordCloudWidgetState extends State<WordCloudWidget> {
  String? selectedWord;

  final List<Map<String, dynamic>> dreamWords = [
    {'word': 'flying', 'frequency': 45, 'size': 18.0},
    {'word': 'water', 'frequency': 38, 'size': 16.0},
    {'word': 'family', 'frequency': 32, 'size': 15.0},
    {'word': 'house', 'frequency': 28, 'size': 14.0},
    {'word': 'running', 'frequency': 25, 'size': 13.0},
    {'word': 'school', 'frequency': 22, 'size': 12.0},
    {'word': 'animals', 'frequency': 20, 'size': 12.0},
    {'word': 'falling', 'frequency': 18, 'size': 11.0},
    {'word': 'friends', 'frequency': 16, 'size': 11.0},
    {'word': 'car', 'frequency': 15, 'size': 10.0},
    {'word': 'forest', 'frequency': 13, 'size': 10.0},
    {'word': 'ocean', 'frequency': 12, 'size': 9.0},
    {'word': 'mountain', 'frequency': 10, 'size': 9.0},
    {'word': 'city', 'frequency': 9, 'size': 8.0},
    {'word': 'light', 'frequency': 8, 'size': 8.0},
  ];

  List<Color> get wordColors => [
    AppTheme.lightTheme.colorScheme.primary,
    AppTheme.lightTheme.colorScheme.secondary,
    AppTheme.lightTheme.colorScheme.tertiary,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.h,
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedWord != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Selected: $selectedWord',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () => setState(() => selectedWord = null),
                    child: CustomIconWidget(
                      iconName: 'close',
                      size: 16,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],
          Expanded(
            child: Semantics(
              label: "Word cloud showing frequently used dream keywords",
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children:
                      dreamWords.asMap().entries.map((entry) {
                        final index = entry.key;
                        final wordData = entry.value;
                        final word = wordData['word'] as String;
                        final frequency = wordData['frequency'] as int;
                        final size = wordData['size'] as double;
                        final color = wordColors[index % wordColors.length];
                        final isSelected = selectedWord == word;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWord = isSelected ? null : word;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? color.withValues(alpha: 0.2)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  isSelected
                                      ? Border.all(color: color, width: 1)
                                      : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  word,
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize: size.sp,
                                        color: color,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                      ),
                                ),
                                if (isSelected) ...[
                                  Text(
                                    '$frequency times',
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontSize: 8.sp,
                                          color: color.withValues(alpha: 0.7),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class DreamEntryDotWidget extends StatelessWidget {
  final int dreamCount;
  final double intensity;
  final String mood;

  const DreamEntryDotWidget({
    super.key,
    required this.dreamCount,
    required this.intensity,
    required this.mood,
  });

  Color _getMoodColor() {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'peaceful':
        return AppTheme.getSuccessColor();
      case 'anxious':
      case 'fearful':
      case 'nightmare':
        return AppTheme.lightTheme.colorScheme.error;
      case 'confused':
      case 'strange':
      case 'mysterious':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'sad':
      case 'melancholy':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  double _getDotSize() {
    if (dreamCount == 0) return 0;
    if (dreamCount == 1) return 8;
    if (dreamCount == 2) return 12;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    if (dreamCount == 0) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'add',
            color: AppTheme.lightTheme.colorScheme.outline,
            size: 4,
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: _getDotSize(),
          height: _getDotSize(),
          decoration: BoxDecoration(
            color: _getMoodColor().withValues(alpha: intensity),
            shape: BoxShape.circle,
            border: Border.all(color: _getMoodColor(), width: 1),
          ),
        ),
        if (dreamCount > 1)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Center(
                child: Text(
                  dreamCount.toString(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
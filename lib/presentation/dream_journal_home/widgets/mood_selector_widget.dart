import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MoodSelectorWidget extends StatefulWidget {
  final String? selectedMood;
  final Function(String) onMoodSelected;
  final bool isVisible;

  const MoodSelectorWidget({
    Key? key,
    this.selectedMood,
    required this.onMoodSelected,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<MoodSelectorWidget> createState() => _MoodSelectorWidgetState();
}

class _MoodSelectorWidgetState extends State<MoodSelectorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> moods = [
    {'name': 'happy', 'emoji': '😊'},
    {'name': 'peaceful', 'emoji': '😌'},
    {'name': 'excited', 'emoji': '🤩'},
    {'name': 'confused', 'emoji': '😕'},
    {'name': 'anxious', 'emoji': '😰'},
    {'name': 'sad', 'emoji': '😢'},
    {'name': 'angry', 'emoji': '😠'},
    {'name': 'neutral', 'emoji': '😐'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MoodSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 10.h),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'mood',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'How did this dream make you feel?',
                        style: AppTheme.lightTheme.textTheme.titleSmall
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children:
                        moods.map((mood) => _buildMoodChip(mood)).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoodChip(Map<String, String> mood) {
    final isSelected = widget.selectedMood == mood['name'];

    return GestureDetector(
      onTap: () => widget.onMoodSelected(mood['name']!),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.secondaryContainer
                      .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.3,
                    ),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mood['emoji']!, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 1.w),
            Text(
              mood['name']!.capitalize(),
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color:
                    isSelected
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

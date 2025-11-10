import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MoodSelectorWidget extends StatefulWidget {
  final String? selectedMood;
  final Function(String) onMoodChanged;

  const MoodSelectorWidget({
    Key? key,
    required this.selectedMood,
    required this.onMoodChanged,
  }) : super(key: key);

  @override
  State<MoodSelectorWidget> createState() => _MoodSelectorWidgetState();
}

class _MoodSelectorWidgetState extends State<MoodSelectorWidget> {
  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Happy', 'value': 'happy'},
    {'emoji': '😌', 'label': 'Peaceful', 'value': 'peaceful'},
    {'emoji': '😴', 'label': 'Sleepy', 'value': 'sleepy'},
    {'emoji': '😰', 'label': 'Anxious', 'value': 'anxious'},
    {'emoji': '😨', 'label': 'Scared', 'value': 'scared'},
    {'emoji': '😢', 'label': 'Sad', 'value': 'sad'},
    {'emoji': '😍', 'label': 'Excited', 'value': 'excited'},
    {'emoji': '🤔', 'label': 'Confused', 'value': 'confused'},
    {'emoji': '😇', 'label': 'Serene', 'value': 'serene'},
    {'emoji': '😤', 'label': 'Frustrated', 'value': 'frustrated'},
    {'emoji': '🥰', 'label': 'Loved', 'value': 'loved'},
    {'emoji': '😎', 'label': 'Confident', 'value': 'confident'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How did this dream make you feel?',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 2.h,
                childAspectRatio: 1.0,
              ),
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                final mood = _moods[index];
                return _buildMoodItem(mood);
              },
            ),
          ),
          if (widget.selectedMood != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getMoodEmoji(widget.selectedMood!),
                    style: TextStyle(fontSize: 5.w),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Feeling ${_getMoodLabel(widget.selectedMood!)}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color:
                          AppTheme.lightTheme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () => widget.onMoodChanged(''),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color:
                          AppTheme.lightTheme.colorScheme.onSecondaryContainer,
                      size: 4.w,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodItem(Map<String, dynamic> mood) {
    final isSelected = widget.selectedMood == mood['value'];

    return GestureDetector(
      onTap: () => widget.onMoodChanged(mood['value']),
      child: Container(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.lightTheme.colorScheme.secondary.withValues(
                    alpha: 0.1,
                  )
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood['emoji'], style: TextStyle(fontSize: 6.w)),
            SizedBox(height: 0.5.h),
            Text(
              mood['label'],
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(String moodValue) {
    final mood = _moods.firstWhere(
      (m) => m['value'] == moodValue,
      orElse: () => {'emoji': '😊'},
    );
    return mood['emoji'];
  }

  String _getMoodLabel(String moodValue) {
    final mood = _moods.firstWhere(
      (m) => m['value'] == moodValue,
      orElse: () => {'label': 'Happy'},
    );
    return mood['label'];
  }
}

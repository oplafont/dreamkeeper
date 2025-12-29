import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearchFiltersChanged;
  final VoidCallback onClose;

  const AdvancedSearchWidget({
    super.key,
    required this.onSearchFiltersChanged,
    required this.onClose,
  });

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  final TextEditingController _keywordsController = TextEditingController();
  String _selectedEmotion = 'all';
  String _selectedTimeRange = 'all_time';
  List<String> _selectedSymbols = [];
  RangeValues _viewsRange = const RangeValues(0, 1000);
  RangeValues _resonanceRange = const RangeValues(0, 100);

  final List<String> _emotions = [
    'all',
    'Joyful',
    'Anxious',
    'Curious',
    'Nostalgic',
    'Amused',
    'Peaceful',
    'Fearful',
    'Excited'
  ];

  final List<String> _timeRanges = [
    'all_time',
    'today',
    'this_week',
    'this_month',
    'this_year'
  ];

  final List<String> _commonSymbols = [
    'flying',
    'water',
    'animals',
    'people',
    'nature',
    'chase',
    'falling',
    'lost',
    'family',
    'travel'
  ];

  @override
  void dispose() {
    _keywordsController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = {
      'keywords': _keywordsController.text,
      'emotion': _selectedEmotion,
      'timeRange': _selectedTimeRange,
      'symbols': _selectedSymbols,
      'viewsMin': _viewsRange.start.round(),
      'viewsMax': _viewsRange.end.round(),
      'resonanceMin': _resonanceRange.start.round(),
      'resonanceMax': _resonanceRange.end.round(),
    };
    widget.onSearchFiltersChanged(filters);
    widget.onClose();
  }

  void _resetFilters() {
    setState(() {
      _keywordsController.clear();
      _selectedEmotion = 'all';
      _selectedTimeRange = 'all_time';
      _selectedSymbols = [];
      _viewsRange = const RangeValues(0, 1000);
      _resonanceRange = const RangeValues(0, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: AppTheme.cardDarkBurgundy,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        border: Border.all(
          color: AppTheme.borderPurple.withAlpha(128),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKeywordsSection(),
                  SizedBox(height: 3.h),
                  _buildEmotionSection(),
                  SizedBox(height: 3.h),
                  _buildTimeRangeSection(),
                  SizedBox(height: 3.h),
                  _buildSymbolsSection(),
                  SizedBox(height: 3.h),
                  _buildViewsRangeSection(),
                  SizedBox(height: 3.h),
                  _buildResonanceRangeSection(),
                  SizedBox(height: 3.h),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderPurple.withAlpha(77),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Advanced Search',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppTheme.textWhite, size: 24),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keywords',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardMediumPurple,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppTheme.borderPurple.withAlpha(77),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _keywordsController,
            style: TextStyle(color: AppTheme.textWhite, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Enter keywords...',
              hintStyle: TextStyle(
                color: AppTheme.textDisabledGray,
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(3.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emotion',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _emotions.map((emotion) {
            final isSelected = _selectedEmotion == emotion;
            return GestureDetector(
              onTap: () => setState(() => _selectedEmotion = emotion),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.coralRed
                      : AppTheme.cardMediumPurple,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.coralRed
                        : AppTheme.borderPurple.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Text(
                  emotion == 'all' ? 'All Emotions' : emotion,
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 12.sp,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Range',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardMediumPurple,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppTheme.borderPurple.withAlpha(77),
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedTimeRange,
            isExpanded: true,
            dropdownColor: AppTheme.cardMediumPurple,
            style: TextStyle(color: AppTheme.textWhite, fontSize: 14.sp),
            underline: const SizedBox(),
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            items: _timeRanges.map((range) {
              return DropdownMenuItem(
                value: range,
                child: Text(_formatTimeRange(range)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedTimeRange = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSymbolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symbols',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _commonSymbols.map((symbol) {
            final isSelected = _selectedSymbols.contains(symbol);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSymbols.remove(symbol);
                  } else {
                    _selectedSymbols.add(symbol);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentRedPurple
                      : AppTheme.cardMediumPurple,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentRedPurple
                        : AppTheme.borderPurple.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Text(
                  '#$symbol',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 12.sp,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildViewsRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Views Range: ${_viewsRange.start.round()} - ${_viewsRange.end.round()}',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.coralRed,
            inactiveTrackColor: AppTheme.cardMediumPurple,
            thumbColor: AppTheme.coralRed,
            overlayColor: AppTheme.coralRed.withAlpha(51),
          ),
          child: RangeSlider(
            values: _viewsRange,
            min: 0,
            max: 1000,
            divisions: 20,
            onChanged: (values) => setState(() => _viewsRange = values),
          ),
        ),
      ],
    );
  }

  Widget _buildResonanceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resonance Range: ${_resonanceRange.start.round()} - ${_resonanceRange.end.round()}',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.coralRed,
            inactiveTrackColor: AppTheme.cardMediumPurple,
            thumbColor: AppTheme.coralRed,
            overlayColor: AppTheme.coralRed.withAlpha(51),
          ),
          child: RangeSlider(
            values: _resonanceRange,
            min: 0,
            max: 100,
            divisions: 10,
            onChanged: (values) => setState(() => _resonanceRange = values),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetFilters,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              side: BorderSide(color: AppTheme.borderPurple, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'Reset',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.coralRed,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'Apply Filters',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeRange(String range) {
    switch (range) {
      case 'all_time':
        return 'All Time';
      case 'today':
        return 'Today';
      case 'this_week':
        return 'This Week';
      case 'this_month':
        return 'This Month';
      case 'this_year':
        return 'This Year';
      default:
        return range;
    }
  }
}

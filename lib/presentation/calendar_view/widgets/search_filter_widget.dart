import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String?) onMoodFilter;
  final Function(String?) onCategoryFilter;
  final VoidCallback onClearFilters;

  const SearchFilterWidget({
    super.key,
    required this.onSearchChanged,
    required this.onMoodFilter,
    required this.onCategoryFilter,
    required this.onClearFilters,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMood;
  String? _selectedCategory;
  bool _isExpanded = false;

  final List<String> _moods = [
    'Happy',
    'Peaceful',
    'Anxious',
    'Fearful',
    'Confused',
    'Sad',
    'Mysterious',
  ];

  final List<String> _categories = [
    'Lucid',
    'Nightmare',
    'Recurring',
    'Prophetic',
    'Adventure',
    'Romance',
    'Flying',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search dreams, keywords, or tags...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'search',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  widget.onSearchChanged('');
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: CustomIconWidget(
                                    iconName: 'clear',
                                    color:
                                        AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.lightTheme.colorScheme.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                    ),
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color:
                          _isExpanded
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'tune',
                      color:
                          _isExpanded
                              ? Colors.white
                              : AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filters section
          if (_isExpanded) ...[
            Container(
              width: double.infinity,
              height: 1,
              color: AppTheme.lightTheme.colorScheme.outline.withValues(
                alpha: 0.1,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood filter
                  Text(
                    'Filter by Mood',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children:
                        _moods
                            .map(
                              (mood) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedMood =
                                        _selectedMood == mood ? null : mood;
                                  });
                                  widget.onMoodFilter(_selectedMood);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _selectedMood == mood
                                            ? AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .secondary
                                            : AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .secondary
                                                .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    mood,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color:
                                              _selectedMood == mood
                                                  ? Colors.white
                                                  : AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .secondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: 2.h),
                  // Category filter
                  Text(
                    'Filter by Category',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children:
                        _categories
                            .map(
                              (category) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory =
                                        _selectedCategory == category
                                            ? null
                                            : category;
                                  });
                                  widget.onCategoryFilter(_selectedCategory);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _selectedCategory == category
                                            ? AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .tertiary
                                            : AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .tertiary
                                                .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color:
                                              _selectedCategory == category
                                                  ? Colors.white
                                                  : AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .tertiary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: 2.h),
                  // Clear filters button
                  if (_selectedMood != null || _selectedCategory != null)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = null;
                            _selectedCategory = null;
                          });
                          widget.onClearFilters();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'clear_all',
                                color: AppTheme.lightTheme.colorScheme.error,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Clear Filters',
                                style: AppTheme.lightTheme.textTheme.labelMedium
                                    ?.copyWith(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
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
}

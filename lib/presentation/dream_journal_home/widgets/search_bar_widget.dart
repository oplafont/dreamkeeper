import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final bool isExpanded;
  final String searchQuery;

  const SearchBarWidget({
    Key? key,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.isExpanded,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.searchQuery);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
        Future.delayed(Duration(milliseconds: 200), () {
          _focusNode.requestFocus();
        });
      } else {
        _animationController.reverse();
        _focusNode.unfocus();
      }
    }

    if (widget.searchQuery != oldWidget.searchQuery &&
        _textController.text != widget.searchQuery) {
      _textController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: widget.isExpanded ? 12.h : 6.h,
          child: Column(
            children: [
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        widget.isExpanded
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                    width: widget.isExpanded ? 2 : 1,
                  ),
                  boxShadow:
                      widget.isExpanded
                          ? [
                            BoxShadow(
                              color: AppTheme.lightTheme.colorScheme.secondary
                                  .withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                          : [],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color:
                            widget.isExpanded
                                ? AppTheme.lightTheme.colorScheme.secondary
                                : AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        onChanged: widget.onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search dreams, tags, or moods...',
                          hintStyle: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.5.h,
                          ),
                        ),
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                    if (widget.searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _textController.clear();
                          widget.onSearchChanged('');
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: CustomIconWidget(
                            iconName: 'clear',
                            color:
                                AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                            size: 18,
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: widget.onFilterTap,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        margin: EdgeInsets.only(right: 2.w),
                        decoration: BoxDecoration(
                          color: AppTheme
                              .lightTheme
                              .colorScheme
                              .secondaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'tune',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isExpanded) ...[
                SizedBox(height: 1.h),
                Container(
                  height: 5.h,
                  child: Transform.translate(
                    offset: Offset(0, (1 - _expandAnimation.value) * 5.h),
                    child: Opacity(
                      opacity: _expandAnimation.value,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: Row(
                          children: [
                            _buildQuickFilter('Recent', 'schedule'),
                            _buildQuickFilter('Lucid', 'visibility'),
                            _buildQuickFilter('Nightmares', 'warning'),
                            _buildQuickFilter('Flying', 'flight'),
                            _buildQuickFilter('Water', 'waves'),
                            _buildQuickFilter('Animals', 'pets'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickFilter(String label, String iconName) {
    return GestureDetector(
      onTap: () => widget.onSearchChanged(label.toLowerCase()),
      child: Container(
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.secondaryContainer.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 14,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

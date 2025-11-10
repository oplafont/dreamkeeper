import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DreamTagsWidget extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;

  const DreamTagsWidget({
    Key? key,
    required this.selectedTags,
    required this.onTagsChanged,
  }) : super(key: key);

  @override
  State<DreamTagsWidget> createState() => _DreamTagsWidgetState();
}

class _DreamTagsWidgetState extends State<DreamTagsWidget> {
  final TextEditingController _customTagController = TextEditingController();
  final List<String> _predefinedTags = [
    'Nightmare',
    'Lucid',
    'Recurring',
    'Flying',
    'Water',
    'Animals',
    'Family',
    'Work',
    'Adventure',
    'Romance',
    'Scary',
    'Peaceful',
    'Vivid',
    'Symbolic',
    'Prophetic',
  ];

  void _toggleTag(String tag) {
    List<String> updatedTags = List.from(widget.selectedTags);

    if (updatedTags.contains(tag)) {
      updatedTags.remove(tag);
    } else {
      updatedTags.add(tag);
    }

    widget.onTagsChanged(updatedTags);
  }

  void _addCustomTag() {
    final customTag = _customTagController.text.trim();
    if (customTag.isNotEmpty && !widget.selectedTags.contains(customTag)) {
      List<String> updatedTags = List.from(widget.selectedTags);
      updatedTags.add(customTag);
      widget.onTagsChanged(updatedTags);
      _customTagController.clear();
    }
  }

  void _showCustomTagDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Add Custom Tag',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            content: TextField(
              controller: _customTagController,
              decoration: const InputDecoration(
                hintText: 'Enter tag name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) {
                _addCustomTag();
                Navigator.of(context).pop();
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _addCustomTag();
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _customTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dream Tags',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 12.h,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._predefinedTags.map((tag) => _buildTagChip(tag)),
                  SizedBox(width: 2.w),
                  _buildAddCustomTagButton(),
                ],
              ),
            ),
          ),
          if (widget.selectedTags.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              'Selected Tags (${widget.selectedTags.length})',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children:
                  widget.selectedTags
                      .map((tag) => _buildSelectedTag(tag))
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    final isSelected = widget.selectedTags.contains(tag);

    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: GestureDetector(
        onTap: () => _toggleTag(tag),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color:
                  isSelected
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddCustomTagButton() {
    return GestureDetector(
      onTap: _showCustomTagDialog,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'add',
              color: AppTheme.lightTheme.colorScheme.secondary,
              size: 4.w,
            ),
            SizedBox(width: 1.w),
            Text(
              'Custom',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: () => _toggleTag(tag),
            child: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSecondaryContainer,
              size: 3.w,
            ),
          ),
        ],
      ),
    );
  }
}

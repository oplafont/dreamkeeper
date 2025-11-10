import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RichTextEditorWidget extends StatefulWidget {
  final String initialText;
  final Function(String) onTextChanged;
  final String placeholder;

  const RichTextEditorWidget({
    Key? key,
    required this.initialText,
    required this.onTextChanged,
    this.placeholder = 'Describe your dream...',
  }) : super(key: key);

  @override
  State<RichTextEditorWidget> createState() => _RichTextEditorWidgetState();
}

class _RichTextEditorWidgetState extends State<RichTextEditorWidget> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isToolbarVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();

    if (widget.initialText.isNotEmpty) {
      _controller.document = Document()..insert(0, widget.initialText);
    }

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final text = _controller.document.toPlainText();
    widget.onTextChanged(text);
  }

  void _onFocusChanged() {
    setState(() {
      _isToolbarVisible = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
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
            'Dream Description',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.outline,
                width: _focusNode.hasFocus ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                if (_isToolbarVisible) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                    child: QuillSimpleToolbar(
                      controller: _controller,
                      config: QuillSimpleToolbarConfig(
                        showBoldButton: true,
                        showItalicButton: true,
                        showUnderLineButton: true,
                        showStrikeThrough: false,
                        showInlineCode: false,
                        showColorButton: false,
                        showBackgroundColorButton: false,
                        showClearFormat: true,
                        showAlignmentButtons: false,
                        showLeftAlignment: false,
                        showCenterAlignment: false,
                        showRightAlignment: false,
                        showJustifyAlignment: false,
                        showHeaderStyle: false,
                        showListNumbers: true,
                        showListBullets: true,
                        showListCheck: false,
                        showCodeBlock: false,
                        showQuote: false,
                        showIndent: false,
                        showLink: false,
                        showUndo: true,
                        showRedo: true,
                        showDirection: false,
                        showSearchButton: false,
                        showSubscript: false,
                        showSuperscript: false,
                        showSmallButton: false,
                        multiRowsDisplay: false,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Container(
                  constraints: BoxConstraints(minHeight: 30.h, maxHeight: 50.h),
                  child: QuillEditor.basic(
                    controller: _controller,
                    focusNode: _focusNode,
                    config: QuillEditorConfig(
                      padding: EdgeInsets.all(4.w),
                      placeholder: widget.placeholder,
                      expands: false,
                      scrollable: true,
                      showCursor: true,
                      paintCursorAboveText: true,
                      enableInteractiveSelection: true,
                      minHeight: 30.h,
                      maxHeight: 50.h,
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                            height: 1.5,
                            fontSize: 14.sp,
                          ),
                          const HorizontalSpacing(8, 8),
                          const VerticalSpacing(8, 8),
                          const VerticalSpacing(0, 0),
                          const BoxDecoration(),
                        ),
                        placeHolder: DefaultTextBlockStyle(
                          AppTheme.lightTheme.textTheme.bodyMedium!.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                            fontSize: 14.sp,
                          ),
                          const HorizontalSpacing(8, 8),
                          const VerticalSpacing(8, 8),
                          const VerticalSpacing(0, 0),
                          const BoxDecoration(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  'Tap the text area to show formatting options. Be as detailed as possible to capture the essence of your dream.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

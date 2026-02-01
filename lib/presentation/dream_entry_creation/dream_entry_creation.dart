import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../providers/dream_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/clarity_score_widget.dart';
import './widgets/dream_tags_widget.dart';
import './widgets/image_attachment_widget.dart';
import './widgets/mood_selector_widget.dart';
import './widgets/rich_text_editor_widget.dart';
import './widgets/sleep_quality_widget.dart';
import './widgets/voice_recording_widget.dart';

class DreamEntryCreation extends StatefulWidget {
  const DreamEntryCreation({Key? key}) : super(key: key);

  @override
  State<DreamEntryCreation> createState() => _DreamEntryCreationState();
}

class _DreamEntryCreationState extends State<DreamEntryCreation>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  // Form data
  String _dreamText = '';
  List<String> _selectedTags = [];
  String? _selectedMood;
  List<XFile> _attachedImages = [];
  double _sleepQuality = 5.0;
  double _clarityScore = 7.0;
  DateTime _dreamDate = DateTime.now();
  TimeOfDay _dreamTime = TimeOfDay.now();
  String? _audioRecordingPath;

  // UI state
  bool _hasUnsavedChanges = false;
  bool _isAutoSaving = false;
  DateTime? _lastAutoSave;
  bool _showDetails = false;
  bool _isSaving = false;

  // Text controllers
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // Form validation
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _startAutoSave();
  }

  void _startAutoSave() {
    // Auto-save every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _hasUnsavedChanges) {
        _performAutoSave();
        _startAutoSave();
      }
    });
  }

  void _performAutoSave() {
    setState(() {
      _isAutoSaving = true;
      _lastAutoSave = DateTime.now();
    });

    // Simulate auto-save
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isAutoSaving = false;
          _hasUnsavedChanges = false;
        });
      }
    });
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dreamDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: AppTheme.lightTheme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dreamDate) {
      setState(() {
        _dreamDate = picked;
      });
      _markAsChanged();
    }
  }

  // NEW: Quick date preset for 'Last Night'
  void _setLastNight() {
    final now = DateTime.now();
    final lastNight = DateTime(now.year, now.month, now.day - 1, 23, 0);

    setState(() {
      _dreamDate = lastNight;
      _dreamTime = TimeOfDay(hour: 23, minute: 0);
    });
    _markAsChanged();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dreamTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: AppTheme.lightTheme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dreamTime) {
      setState(() {
        _dreamTime = picked;
      });
      _markAsChanged();
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Unsaved Changes',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Text(
          'You have unsaved changes. Do you want to discard them?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Discard',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _handleRecordingComplete(String audioPath, String transcribedText) {
    setState(() {
      _audioRecordingPath = audioPath;

      // Insert transcribed text into dream content field
      if (transcribedText.isNotEmpty) {
        final currentText = _contentController.text;
        final newText = currentText.isEmpty
            ? transcribedText
            : '$currentText\n\n$transcribedText';

        _contentController.text = newText;
        _contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
      }
    });
  }

  Future<void> _saveDream() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add dream content')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dreamProvider = context.read<DreamProvider>();

      // Determine sleep quality string
      String sleepQualityStr;
      if (_sleepQuality <= 2.5) {
        sleepQualityStr = 'poor';
      } else if (_sleepQuality <= 5.0) {
        sleepQualityStr = 'fair';
      } else if (_sleepQuality <= 7.5) {
        sleepQualityStr = 'good';
      } else {
        sleepQualityStr = 'excellent';
      }

      final dream = await dreamProvider.createDream(
        content: _contentController.text,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        mood: _selectedMood,
        tags: _selectedTags.isEmpty ? null : _selectedTags,
        sleepQuality: sleepQualityStr,
        clarityScore: _clarityScore.round(),
        performAIAnalysis: true,
      );

      if (dream != null && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dream saved and analyzed!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dreamProvider.error ?? 'Failed to save dream'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving dream: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Record Your Dream',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: Colors.white,
              size: 6.w,
            ),
          ),
          actions: [
            if (_isAutoSaving)
              Container(
                margin: EdgeInsets.only(right: 4.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Saving...',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              margin: EdgeInsets.only(right: 4.w),
              child: ElevatedButton(
                onPressed: _saveDream,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Save',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Main Voice Recording Section - Central and Large
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h), // Extra space for app bar
                    // Big Voice Recording Button
                    Container(
                      width: 50.w,
                      height: 50.w,
                      child: VoiceRecordingWidget(
                        onRecordingComplete: _handleRecordingComplete,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      'Tap to record your dream',
                      style: AppTheme.lightTheme.textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      'Speak naturally and clearly about what you remember',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 6.h),

                    // Quick Text Entry (Optional)
                    if (_dreamText.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Dream:',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              _dreamText,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],

                    // Add Details Button
                    if (!_showDetails)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showDetails = true;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Add more details',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            SizedBox(width: 2.w),
                            CustomIconWidget(
                              iconName: 'expand_more',
                              color: Colors.white,
                              size: 5.w,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Optional Details Section
              if (_showDetails) ...[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Additional Details',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showDetails = false;
                                });
                              },
                              icon: CustomIconWidget(
                                iconName: 'expand_less',
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                size: 6.w,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 3.h),

                        // Rich Text Editor
                        RichTextEditorWidget(
                          initialText: _dreamText,
                          onTextChanged: (text) {
                            _dreamText = text;
                            _markAsChanged();
                          },
                          placeholder: 'Add more details or edit your dream...',
                        ),

                        SizedBox(height: 4.h),

                        // Date and Time Selection with Quick Preset
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'When did you have this dream?',
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _setLastNight,
                                    icon: Icon(
                                      Icons.nightlight_round,
                                      size: 4.w,
                                    ),
                                    label: Text('Last Night'),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                        vertical: 1.h,
                                      ),
                                      side: BorderSide(
                                        color: AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _selectDate,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .surface,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .outline,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            CustomIconWidget(
                                              iconName: 'calendar_today',
                                              color: AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .secondary,
                                              size: 5.w,
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              '${_dreamDate.day}/${_dreamDate.month}/${_dreamDate.year}',
                                              style: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _selectTime,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .surface,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .outline,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            CustomIconWidget(
                                              iconName: 'access_time',
                                              color: AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .secondary,
                                              size: 5.w,
                                            ),
                                            SizedBox(width: 2.w),
                                            Text(
                                              _dreamTime.format(context),
                                              style: AppTheme
                                                  .lightTheme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Mood Selector
                        MoodSelectorWidget(
                          selectedMood: _selectedMood,
                          onMoodChanged: (mood) {
                            setState(() {
                              _selectedMood = mood.isEmpty ? null : mood;
                            });
                            _markAsChanged();
                          },
                        ),

                        SizedBox(height: 4.h),

                        // NEW: Clarity Score Widget
                        ClarityScoreWidget(
                          clarityScore: _clarityScore,
                          onClarityChanged: (score) {
                            setState(() {
                              _clarityScore = score;
                            });
                            _markAsChanged();
                          },
                        ),

                        SizedBox(height: 4.h),

                        // Sleep Quality
                        SleepQualityWidget(
                          sleepQuality: _sleepQuality,
                          onQualityChanged: (quality) {
                            setState(() {
                              _sleepQuality = quality;
                            });
                            _markAsChanged();
                          },
                        ),

                        SizedBox(height: 4.h),

                        // Dream Tags
                        DreamTagsWidget(
                          selectedTags: _selectedTags,
                          onTagsChanged: (tags) {
                            setState(() {
                              _selectedTags = tags;
                            });
                            _markAsChanged();
                          },
                        ),

                        SizedBox(height: 4.h),

                        // Image Attachments
                        ImageAttachmentWidget(
                          attachedImages: _attachedImages,
                          onImagesChanged: (images) {
                            setState(() {
                              _attachedImages = images;
                            });
                            _markAsChanged();
                          },
                        ),

                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
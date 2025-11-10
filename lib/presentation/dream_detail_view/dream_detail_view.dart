import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/dream_image_gallery_widget.dart';
import './widgets/dream_metadata_widget.dart';
import './widgets/pattern_insights_widget.dart';
import './widgets/related_dreams_widget.dart';
import './widgets/share_bottom_sheet_widget.dart';
import './widgets/voice_playback_widget.dart';

class DreamDetailView extends StatefulWidget {
  const DreamDetailView({Key? key}) : super(key: key);

  @override
  State<DreamDetailView> createState() => _DreamDetailViewState();
}

class _DreamDetailViewState extends State<DreamDetailView> {
  bool _isEditMode = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final ScrollController _scrollController = ScrollController();

  // Mock dream data
  final Map<String, dynamic> _dreamData = {
    'id': 1,
    'title': 'Flying Over the Ocean',
    'description':
        '''I found myself soaring high above a vast, crystal-clear ocean. The water below was the most beautiful shade of turquoise I had ever seen, and I could see schools of colorful fish swimming beneath the surface. The feeling of flight was incredibly liberating - I wasn't using wings or any device, just my own will to stay airborne.

As I flew, I noticed small islands dotting the ocean, each one unique and mysterious. Some had lush tropical vegetation, while others were rocky and barren. I felt drawn to explore them, but every time I tried to descend, I would wake up slightly, then drift back into the dream.

The sun was setting, painting the sky in brilliant oranges and purples. The whole experience felt deeply peaceful and spiritual, as if I was connected to something greater than myself.''',
    'creationDate': DateTime.now().subtract(const Duration(days: 2)),
    'sleepQuality': 4.5,
    'mood': 'Peaceful',
    'tags': ['Flying', 'Ocean', 'Islands', 'Spiritual', 'Peaceful'],
    'audioPath': '/path/to/voice_recording.m4a',
    'images': [
      {
        'url':
            'https://images.unsplash.com/photo-1580503013542-099c082f1c00',
        'semanticLabel':
            'Aerial view of crystal clear turquoise ocean water with small tropical islands scattered across the horizon under a sunset sky',
      },
      {
        'url':
            'https://images.unsplash.com/photo-1549112486-c30d11673de9',
        'semanticLabel':
            'Person silhouette appearing to fly or jump against a dramatic orange and purple sunset sky with clouds',
      },
    ],
  };

  // Mock related dreams
  final List<Map<String, dynamic>> _relatedDreams = [
    {
      'id': 2,
      'title': 'Swimming with Dolphins',
      'description':
          'I was underwater, breathing normally, swimming alongside a pod of friendly dolphins in clear blue water.',
      'creationDate': DateTime.now().subtract(const Duration(days: 7)),
      'mood': 'Joyful',
      'tags': ['Ocean', 'Dolphins', 'Swimming', 'Underwater'],
    },
    {
      'id': 3,
      'title': 'Mountain Peak Flight',
      'description':
          'Flying over snow-capped mountains, feeling the cold air rush past as I soared between the peaks.',
      'creationDate': DateTime.now().subtract(const Duration(days: 14)),
      'mood': 'Adventurous',
      'tags': ['Flying', 'Mountains', 'Snow', 'Adventure'],
    },
    {
      'id': 4,
      'title': 'Tropical Island Paradise',
      'description':
          'Walking on a pristine beach with white sand and palm trees, completely alone but feeling at peace.',
      'creationDate': DateTime.now().subtract(const Duration(days: 21)),
      'mood': 'Serene',
      'tags': ['Islands', 'Beach', 'Tropical', 'Peaceful'],
    },
  ];

  // Mock pattern insights
  final List<Map<String, dynamic>> _patternInsights = [
    {
      'type': 'recurring',
      'title': 'Flight Dreams',
      'description':
          'You\'ve had 8 dreams involving flying in the past month. This often represents a desire for freedom or escape from daily constraints.',
      'frequency': 8,
    },
    {
      'type': 'theme',
      'title': 'Water Elements',
      'description':
          'Ocean and water appear frequently in your dreams, suggesting emotional depth and subconscious exploration.',
      'frequency': 12,
    },
    {
      'type': 'emotion',
      'title': 'Peaceful States',
      'description':
          'Most of your recent dreams have peaceful or positive emotions, indicating good mental well-being.',
      'frequency': 15,
    },
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: _dreamData['title'] as String? ?? '',
    );
    _descriptionController = TextEditingController(
      text: _dreamData['description'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDreamContent(),
              DreamMetadataWidget(
                dreamData: _dreamData,
                onEditTags: _showEditTagsDialog,
              ),
              DreamImageGalleryWidget(
                images:
                    (_dreamData['images'] as List?)
                        ?.cast<Map<String, dynamic>>() ??
                    [],
              ),
              VoicePlaybackWidget(
                audioPath: _dreamData['audioPath'] as String?,
              ),
              PatternInsightsWidget(insights: _patternInsights),
              RelatedDreamsWidget(
                relatedDreams: _relatedDreams,
                onDreamTap: _navigateToRelatedDream,
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(
                alpha: 0.3,
              ),
              width: 1,
            ),
          ),
          child: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
      title: Text(
        _isEditMode ? 'Edit Dream' : 'Dream Details',
        style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
      ),
      actions: [
        GestureDetector(
          onTap: _toggleEditMode,
          child: Container(
            margin: EdgeInsets.all(2.w),
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color:
                  _isEditMode
                      ? AppTheme.getSuccessColor()
                      : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _isEditMode
                        ? AppTheme.getSuccessColor()
                        : AppTheme.lightTheme.colorScheme.outline.withValues(
                          alpha: 0.3,
                        ),
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: _isEditMode ? 'check' : 'edit',
              color:
                  _isEditMode
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        GestureDetector(
          onTap: _showShareBottomSheet,
          child: Container(
            margin: EdgeInsets.all(2.w),
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.3,
                ),
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDreamContent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isEditMode ? _buildEditableTitle() : _buildStaticTitle(),
          SizedBox(height: 3.h),
          _isEditMode ? _buildEditableDescription() : _buildStaticDescription(),
        ],
      ),
    );
  }

  Widget _buildStaticTitle() {
    return Text(
      _dreamData['title'] as String? ?? 'Untitled Dream',
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildEditableTitle() {
    return TextFormField(
      controller: _titleController,
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Enter dream title...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.3,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      ),
      onChanged: (value) {
        setState(() {
          _dreamData['title'] = value;
        });
      },
    );
  }

  Widget _buildStaticDescription() {
    return Text(
      _dreamData['description'] as String? ?? 'No description available.',
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildEditableDescription() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: null,
      minLines: 5,
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Describe your dream in detail...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.3,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      ),
      onChanged: (value) {
        setState(() {
          _dreamData['description'] = value;
        });
      },
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });

    if (!_isEditMode) {
      // Save changes
      _dreamData['title'] = _titleController.text;
      _dreamData['description'] = _descriptionController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dream updated successfully'),
          backgroundColor: AppTheme.getSuccessColor(),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showEditTagsDialog() {
    final tags = (_dreamData['tags'] as List?)?.cast<String>() ?? [];
    final TextEditingController tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Edit Tags',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: 80.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: tagController,
                      decoration: InputDecoration(
                        hintText: 'Add new tag...',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            if (tagController.text.isNotEmpty) {
                              setDialogState(() {
                                tags.add(tagController.text);
                                tagController.clear();
                              });
                            }
                          },
                          child: CustomIconWidget(
                            iconName: 'add',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children:
                          tags
                              .map(
                                (tag) => Chip(
                                  label: Text(tag),
                                  deleteIcon: CustomIconWidget(
                                    iconName: 'close',
                                    color:
                                        AppTheme.lightTheme.colorScheme.error,
                                    size: 16,
                                  ),
                                  onDeleted: () {
                                    setDialogState(() {
                                      tags.remove(tag);
                                    });
                                  },
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _dreamData['tags'] = tags;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheetWidget(dreamData: _dreamData),
    );
  }

  void _navigateToRelatedDream(Map<String, dynamic> dream) {
    // Navigate to another dream detail view with the selected dream data
    Navigator.pushNamed(context, '/dream-detail-view');
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/dream.dart';
import '../../providers/dream_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class DreamDetailView extends StatefulWidget {
  const DreamDetailView({super.key});

  @override
  State<DreamDetailView> createState() => _DreamDetailViewState();
}

class _DreamDetailViewState extends State<DreamDetailView> {
  bool _isEditMode = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final ScrollController _scrollController = ScrollController();
  Dream? _dream;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDream();
    });
  }

  Future<void> _loadDream() async {
    final dreamProvider = context.read<DreamProvider>();

    // First check if we have a selected dream
    if (dreamProvider.selectedDream != null) {
      setState(() {
        _dream = dreamProvider.selectedDream;
        _titleController.text = _dream?.title ?? '';
        _contentController.text = _dream?.content ?? '';
        _isLoading = false;
      });
      return;
    }

    // If not, try to get dream ID from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      final dream = await dreamProvider.loadDream(args);
      if (mounted) {
        setState(() {
          _dream = dream;
          _titleController.text = dream?.title ?? '';
          _contentController.text = dream?.content ?? '';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDarkest,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryDarkPurple,
          title: const Text('Dream Details'),
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentPurple),
        ),
      );
    }

    if (_dream == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDarkest,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryDarkPurple,
          title: const Text('Dream Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.textMediumGray),
              SizedBox(height: 2.h),
              Text(
                'Dream not found',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDarkest,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDreamContent(),
              _buildMetadataSection(),
              if (_dream!.hasAIAnalysis) _buildAIAnalysisSection(),
              _buildTagsSection(),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryDarkPurple,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, color: AppTheme.textWhite),
      ),
      title: Text(
        _isEditMode ? 'Edit Dream' : 'Dream Details',
        style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
          color: AppTheme.textWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleEditMode,
          icon: Icon(
            _isEditMode ? Icons.check : Icons.edit,
            color: _isEditMode ? AppTheme.successColor : AppTheme.textWhite,
          ),
          tooltip: _isEditMode ? 'Save' : 'Edit',
        ),
        IconButton(
          onPressed: _confirmDelete,
          icon: Icon(Icons.delete_outline, color: AppTheme.textWhite),
          tooltip: 'Delete',
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
        color: AppTheme.cardDarkPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderPurple.withAlpha(128),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Text(
            _dream!.formattedDate,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.accentPurpleLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),

          // Title
          _isEditMode
              ? TextField(
                  controller: _titleController,
                  style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Dream title...',
                    hintStyle: TextStyle(color: AppTheme.textMediumGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.borderPurple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppTheme.accentPurpleLight,
                        width: 2,
                      ),
                    ),
                  ),
                )
              : Text(
                  _dream!.displayTitle,
                  style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),

          SizedBox(height: 2.h),

          // Content
          _isEditMode
              ? TextField(
                  controller: _contentController,
                  maxLines: null,
                  minLines: 5,
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLightGray,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Describe your dream...',
                    hintStyle: TextStyle(color: AppTheme.textMediumGray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.borderPurple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppTheme.accentPurpleLight,
                        width: 2,
                      ),
                    ),
                  ),
                )
              : Text(
                  _dream!.content,
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLightGray,
                    height: 1.6,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderPurple.withAlpha(128),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dream Details',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Mood
          _buildMetadataRow(
            icon: Icons.emoji_emotions,
            label: 'Mood',
            value: _dream!.mood ?? 'Not set',
            emoji: _dream!.moodEmoji,
          ),

          // Sleep Quality
          _buildMetadataRow(
            icon: Icons.bedtime,
            label: 'Sleep Quality',
            value: _dream!.sleepQuality ?? 'Not set',
            emoji: _dream!.sleepQualityIcon,
          ),

          // Clarity Score
          if (_dream!.clarityScore != null)
            _buildMetadataRow(
              icon: Icons.visibility,
              label: 'Clarity',
              value: '${_dream!.clarityScore}/10',
            ),

          // Dream Type flags
          if (_dream!.isLucid || _dream!.isNightmare || _dream!.isRecurring)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  if (_dream!.isLucid)
                    _buildDreamTypeChip('Lucid', Icons.remove_red_eye, Colors.blue),
                  if (_dream!.isNightmare)
                    _buildDreamTypeChip('Nightmare', Icons.warning, Colors.red),
                  if (_dream!.isRecurring)
                    _buildDreamTypeChip('Recurring', Icons.repeat, Colors.orange),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
    String? emoji,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentPurpleLight, size: 20),
          SizedBox(width: 3.w),
          Text(
            '$label: ',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMediumGray,
            ),
          ),
          if (emoji != null) ...[
            Text(emoji, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 1.w),
          ],
          Expanded(
            child: Text(
              value,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamTypeChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentPurple.withAlpha(30),
            AppTheme.cardDarkPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentPurpleLight.withAlpha(77),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.psychology,
                  color: AppTheme.accentPurpleLight,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'AI Analysis',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Symbols
          if (_dream!.aiSymbols.isNotEmpty) ...[
            _buildAnalysisItem('Symbols', _dream!.aiSymbols.join(', ')),
          ],

          // Emotions
          if (_dream!.aiEmotions.isNotEmpty) ...[
            _buildAnalysisItem('Emotions', _dream!.aiEmotions.join(', ')),
          ],

          // Themes
          if (_dream!.aiThemes.isNotEmpty) ...[
            _buildAnalysisItem('Themes', _dream!.aiThemes.join(', ')),
          ],

          // Full Analysis
          if (_dream!.aiAnalysis != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDarkest.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _dream!.aiAnalysis!['interpretation'] ?? 'Analysis available',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textLightGray,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.accentPurpleLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textLightGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    final allTags = [..._dream!.tags, ..._dream!.aiTags];
    if (allTags.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDarkPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderPurple.withAlpha(128),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: allTags.map((tag) {
              final isAI = _dream!.aiTags.contains(tag);
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: isAI
                      ? AppTheme.accentPurple.withAlpha(30)
                      : AppTheme.cardMediumPurple,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAI
                        ? AppTheme.accentPurpleLight.withAlpha(100)
                        : AppTheme.borderPurple,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAI) ...[
                      Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: AppTheme.accentPurpleLight,
                      ),
                      SizedBox(width: 1.w),
                    ],
                    Text(
                      tag,
                      style: TextStyle(
                        color: isAI
                            ? AppTheme.accentPurpleLight
                            : AppTheme.textLightGray,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _toggleEditMode() async {
    if (_isEditMode) {
      // Save changes
      final dreamProvider = context.read<DreamProvider>();
      final updatedDream = await dreamProvider.updateDream(
        _dream!.id,
        {
          'title': _titleController.text,
          'content': _contentController.text,
        },
      );

      if (updatedDream != null && mounted) {
        setState(() {
          _dream = updatedDream;
          _isEditMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dream updated successfully'),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dreamProvider.error ?? 'Failed to update dream'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() {
        _isEditMode = true;
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Dream?',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        content: Text(
          'This action cannot be undone. Are you sure you want to delete this dream?',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textLightGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMediumGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteDream();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDream() async {
    final dreamProvider = context.read<DreamProvider>();
    final success = await dreamProvider.deleteDream(_dream!.id);

    if (success && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dream deleted'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dreamProvider.error ?? 'Failed to delete dream'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

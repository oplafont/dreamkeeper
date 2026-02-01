import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/dream.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dream_provider.dart';
import '../../theme/app_theme.dart';
import './widgets/dream_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/voice_recording_widget.dart';

class DreamJournalHome extends StatefulWidget {
  const DreamJournalHome({super.key});

  @override
  State<DreamJournalHome> createState() => _DreamJournalHomeState();
}

class _DreamJournalHomeState extends State<DreamJournalHome> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    // Load dreams when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dreamProvider = context.read<DreamProvider>();
      if (!dreamProvider.hasDreams) {
        dreamProvider.loadDreams();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Dream> _filterDreams(List<Dream> dreams) {
    if (_searchQuery.isEmpty) return dreams;

    return dreams.where((dream) {
      return dream.displayTitle.toLowerCase().contains(_searchQuery) ||
          dream.content.toLowerCase().contains(_searchQuery) ||
          dream.tags.any((tag) => tag.toLowerCase().contains(_searchQuery)) ||
          dream.aiTags.any((tag) => tag.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  Future<void> _onVoiceRecordingComplete(String transcription) async {
    final dreamProvider = context.read<DreamProvider>();

    final dream = await dreamProvider.createDream(
      content: transcription,
      title: 'Voice Dream Entry',
    );

    if (dream != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dream recorded and analyzed!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      _showError(dreamProvider.error ?? 'Failed to save dream');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _signOut() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDarkest,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDarkPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Dreams',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: AppTheme.textWhite,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            tooltip: _showSearch ? 'Close Search' : 'Search',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppTheme.textWhite),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Consumer2<AuthProvider, DreamProvider>(
        builder: (context, auth, dreamProvider, _) {
          if (dreamProvider.isLoading && dreamProvider.dreams.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.accentPurple),
            );
          }

          final filteredDreams = _filterDreams(dreamProvider.dreams);

          return RefreshIndicator(
            onRefresh: () => dreamProvider.loadDreams(),
            color: AppTheme.accentPurple,
            backgroundColor: AppTheme.cardDarkPurple,
            child: CustomScrollView(
              slivers: [
                // Greeting Header with Stats
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(4.w),
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
                          'Welcome back, ${auth.displayName}!',
                          style: AppTheme.darkTheme.textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            _buildStatItem(
                              'Dreams',
                              '${dreamProvider.dreamCount}',
                            ),
                            SizedBox(width: 4.w),
                            _buildStatItem(
                              'Lucid',
                              '${dreamProvider.lucidDreams.length}',
                            ),
                            SizedBox(width: 4.w),
                            if (dreamProvider.averageClarityScore > 0)
                              _buildStatItem(
                                'Clarity',
                                '${dreamProvider.averageClarityScore.toStringAsFixed(1)}',
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Voice Recording Button
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: VoiceRecordingWidget(
                      onRecordingComplete: _onVoiceRecordingComplete,
                    ),
                  ),
                ),

                // Text Entry Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.dreamEntryCreation,
                        );
                        if (result == true) {
                          dreamProvider.loadDreams();
                        }
                      },
                      icon: Icon(Icons.edit, color: AppTheme.textWhite),
                      label: Text(
                        'Write Dream Instead',
                        style: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardMediumPurple,
                        foregroundColor: AppTheme.textWhite,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: AppTheme.borderPurple,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                // Search Bar (when active)
                if (_showSearch)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        autofocus: true,
                        style: TextStyle(color: AppTheme.textWhite),
                        decoration: InputDecoration(
                          hintText: 'Search dreams...',
                          hintStyle: TextStyle(color: AppTheme.textMediumGray),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.textMediumGray,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppTheme.textMediumGray,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppTheme.cardMediumPurple,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.borderPurple),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.borderPurple),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.accentPurpleLight,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Dreams (${filteredDreams.length})',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (dreamProvider.isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accentPurpleLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Dreams List or Empty State
                filteredDreams.isEmpty
                    ? SliverFillRemaining(
                        child: EmptyStateWidget(
                          onGetStarted: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.dreamEntryCreation,
                            );
                          },
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final dream = filteredDreams[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              child: DreamCardWidget(
                                dream: dream,
                                onTap: () async {
                                  dreamProvider.selectDream(dream);
                                  final result = await Navigator.pushNamed(
                                    context,
                                    AppRoutes.dreamDetailView,
                                    arguments: dream.id,
                                  );
                                  if (result == true) {
                                    dreamProvider.loadDreams();
                                  }
                                },
                              ),
                            );
                          },
                          childCount: filteredDreams.length,
                        ),
                      ),

                // Bottom padding
                SliverToBoxAdapter(child: SizedBox(height: 10.h)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.accentPurpleLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumGray,
          ),
        ),
      ],
    );
  }
}

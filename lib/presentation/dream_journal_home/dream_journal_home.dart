import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/dream.dart';
import '../../services/auth_service.dart';
import '../../services/dream_service.dart';
import './widgets/dream_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/voice_recording_widget.dart';

class DreamJournalHome extends StatefulWidget {
  const DreamJournalHome({super.key});

  @override
  State<DreamJournalHome> createState() => _DreamJournalHomeState();
}

class _DreamJournalHomeState extends State<DreamJournalHome> {
  final _authService = AuthService();
  final _dreamService = DreamService();
  final _searchController = TextEditingController();

  List<Dream> _dreams = [];
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _dreamStats;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!_authService.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.authScreen);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Load user profile, dreams, and statistics
      final futures = await Future.wait([
        _authService.getUserProfile(),
        _dreamService.getUserDreams(limit: 20),
        _dreamService.getDreamStatistics(),
      ]);

      setState(() {
        _userProfile = futures[0] as Map<String, dynamic>?;
        _dreams =
            (futures[1] as List<Map<String, dynamic>>)
                .map((json) => Dream.fromJson(json))
                .toList();
        _dreamStats = futures[2] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load data: ${e.toString()}');
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Dream> get _filteredDreams {
    if (_searchQuery.isEmpty) return _dreams;

    return _dreams.where((dream) {
      return dream.displayTitle.toLowerCase().contains(_searchQuery) ||
          dream.content.toLowerCase().contains(_searchQuery) ||
          dream.tags.any((tag) => tag.toLowerCase().contains(_searchQuery)) ||
          dream.aiTags.any((tag) => tag.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  Future<void> _onVoiceRecordingComplete(String transcription) async {
    try {
      await _dreamService.createDream(
        content: transcription,
        title: 'Voice Dream Entry',
      );

      // Refresh dreams list
      await _refreshData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dream recorded and analyzed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Failed to save dream: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textWhite,
          ),
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      Navigator.pushReplacementNamed(context, AppRoutes.authScreen);
    } catch (e) {
      _showError('Failed to sign out: ${e.toString()}');
    }
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
            icon: Icon(Icons.logout, color: AppTheme.textWhite),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.accentPurple),
              )
              : RefreshIndicator(
                onRefresh: _refreshData,
                color: AppTheme.accentPurple,
                backgroundColor: AppTheme.cardDarkPurple,
                child: CustomScrollView(
                  slivers: [
                    // Simplified Greeting with clear stats
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
                              'Welcome back!',
                              style: AppTheme.darkTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppTheme.textWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                _buildStatItem('Dreams', '${_dreams.length}'),
                                SizedBox(width: 4.w),
                                _buildStatItem(
                                  'Streak',
                                  '${_dreamStats?['current_streak'] ?? 0} days',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Big Voice Recording Button - Main Feature
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        child: VoiceRecordingWidget(
                          onRecordingComplete: _onVoiceRecordingComplete,
                        ),
                      ),
                    ),

                    // Alternative Action Button - Text Entry
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.dreamEntryCreation,
                            );
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

                    // Simple Search (only when needed)
                    if (_searchQuery.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          child: TextField(
                            onChanged: _onSearchChanged,
                            style: TextStyle(color: AppTheme.textWhite),
                            decoration: InputDecoration(
                              hintText: 'Search dreams...',
                              hintStyle: TextStyle(
                                color: AppTheme.textMediumGray,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppTheme.textMediumGray,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: AppTheme.textMediumGray,
                                ),
                                onPressed: () => _onSearchChanged(''),
                              ),
                              filled: true,
                              fillColor: AppTheme.cardMediumPurple,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.borderPurple,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.borderPurple,
                                ),
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
                              'Recent Dreams (${_filteredDreams.length})',
                              style: AppTheme.darkTheme.textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.textWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (_dreams.isNotEmpty)
                              TextButton(
                                onPressed:
                                    () => _onSearchChanged(
                                      _searchQuery.isEmpty ? ' ' : '',
                                    ),
                                child: Text(
                                  _searchQuery.isEmpty ? 'Search' : 'Clear',
                                  style: TextStyle(
                                    color: AppTheme.accentPurpleLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Dreams List or Empty State
                    _filteredDreams.isEmpty
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
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final dream = _filteredDreams[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              child: DreamCardWidget(
                                dream: dream,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.dreamDetailView,
                                    arguments: dream.id,
                                  );
                                },
                              ),
                            );
                          }, childCount: _filteredDreams.length),
                        ),

                    // Bottom padding
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                  ],
                ),
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
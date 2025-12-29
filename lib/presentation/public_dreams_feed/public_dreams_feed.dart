import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/analytics_service.dart';
import '../../services/dream_cache_service.dart';
import '../../services/dream_service.dart';
import '../../theme/app_theme.dart';
import './widgets/advanced_search_widget.dart';
import './widgets/ai_recommendations_widget.dart';
import './widgets/category_tabs_widget.dart';
import './widgets/feed_dream_card_widget.dart';
import './widgets/sort_options_widget.dart';
import './widgets/symbol_filter_widget.dart';
import './widgets/trending_section_widget.dart';

class PublicDreamsFeed extends StatefulWidget {
  const PublicDreamsFeed({super.key});

  @override
  State<PublicDreamsFeed> createState() => _PublicDreamsFeedState();
}

class _PublicDreamsFeedState extends State<PublicDreamsFeed> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DreamService _dreamService = DreamService();

  String _selectedFilter = 'all';
  bool _showFilterPanel = false;
  bool _showAdvancedSearch = false;
  String _selectedCategory = 'all';
  String _selectedSortOption = 'trending';
  Map<String, dynamic> _searchFilters = {};

  // Pagination state
  List<Map<String, dynamic>> _dreams = [];
  List<Map<String, dynamic>> _trendingDreams = [];
  List<Map<String, dynamic>> _aiRecommendations = [];
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isInitialLoad = true;

  // Real-time subscription channels
  RealtimeChannel? _dreamsChannel;
  RealtimeChannel? _engagementChannel;
  bool _isRealtimeConnected = false;

  // User preferences for AI recommendations
  final Map<String, dynamic> _userPreferences = {
    'themes': 'flying, nature, emotional journeys, lucid dreaming',
    'emotions': ['Joyful', 'Curious', 'Peaceful'],
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _trackFeedView();
    _loadInitialData();
    _setupRealtimeSubscriptions();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoad = true;
    });

    await Future.wait([
      _loadTrendingDreams(),
      _loadAIRecommendations(),
      _loadDreams(refresh: true),
    ]);

    setState(() {
      _isInitialLoad = false;
    });
  }

  Future<void> _loadTrendingDreams() async {
    try {
      final trending = await _dreamService.getTrendingDreams(limit: 5);
      setState(() {
        _trendingDreams = trending;
      });
    } catch (e) {
      print('Failed to load trending dreams: $e');
    }
  }

  Future<void> _loadAIRecommendations() async {
    try {
      final recommendations = await _dreamService.getAIRecommendations(
        userPreferences: _userPreferences,
        limit: 5,
      );
      setState(() {
        _aiRecommendations = recommendations;
      });
    } catch (e) {
      print('Failed to load AI recommendations: $e');
    }
  }

  /// Setup real-time subscriptions for instant sync
  void _setupRealtimeSubscriptions() {
    // Subscribe to new dream submissions
    _dreamsChannel = _dreamService.subscribeToNewDreams(
      onNewDream: _handleNewDreamRealtime,
      onDreamUpdated: _handleDreamUpdateRealtime,
      onDreamDeleted: _handleDreamDeleteRealtime,
    );

    // Subscribe to engagement metric updates
    _engagementChannel = _dreamService.subscribeToEngagementMetrics(
      onEngagementUpdate: _handleEngagementUpdateRealtime,
    );

    setState(() {
      _isRealtimeConnected = true;
    });

    print('✅ Real-time subscriptions established');
  }

  /// Handle new dream submission in real-time
  void _handleNewDreamRealtime(Map<String, dynamic> newDream) {
    print('📨 New dream received via real-time: ${newDream['title']}');

    // Only add if it matches current filters
    if (_shouldIncludeDream(newDream)) {
      setState(() {
        // Insert at the beginning for 'recent' sort, otherwise at appropriate position
        if (_selectedSortOption == 'recent' ||
            _selectedSortOption == 'trending') {
          _dreams.insert(0, newDream);
        } else {
          _dreams.add(newDream);
        }
      });

      // Show subtle notification
      _showNewDreamNotification(newDream);

      // Invalidate cache
      _invalidateCache();
    }
  }

  /// Handle dream update in real-time
  void _handleDreamUpdateRealtime(Map<String, dynamic> updatedDream) {
    print('🔄 Dream updated via real-time: ${updatedDream['id']}');

    setState(() {
      final index = _dreams.indexWhere((d) => d['id'] == updatedDream['id']);
      if (index != -1) {
        _dreams[index] = updatedDream;
      }
    });

    _invalidateCache();
  }

  /// Handle dream deletion in real-time
  void _handleDreamDeleteRealtime(Map<String, dynamic> deletedDream) {
    print('🗑️ Dream deleted via real-time: ${deletedDream['id']}');

    setState(() {
      _dreams.removeWhere((d) => d['id'] == deletedDream['id']);
    });

    _invalidateCache();
  }

  /// Handle engagement metric updates in real-time
  void _handleEngagementUpdateRealtime(Map<String, dynamic> engagement) {
    print('📊 Engagement metrics updated: ${engagement['user_id']}');

    // Update trending dreams if engagement changed significantly
    if (engagement['total_feed_views'] != null) {
      _loadTrendingDreams();
    }
  }

  /// Check if dream should be included based on current filters
  bool _shouldIncludeDream(Map<String, dynamic> dream) {
    // Category filter
    if (_selectedCategory != 'all') {
      switch (_selectedCategory) {
        case 'lucid':
          if (dream['is_lucid'] != true) return false;
          break;
        case 'nightmares':
          if (dream['is_nightmare'] != true) return false;
          break;
        case 'recurring':
          if (dream['is_recurring'] != true) return false;
          break;
        case 'prophetic':
          if (dream['dream_type'] != 'prophetic') return false;
          break;
      }
    }

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      final title = (dream['title'] ?? '').toString().toLowerCase();
      final content = (dream['content'] ?? '').toString().toLowerCase();
      if (!title.contains(searchTerm) && !content.contains(searchTerm)) {
        return false;
      }
    }

    // Advanced filters
    if (_searchFilters.isNotEmpty) {
      if (_searchFilters['emotion'] != null &&
          _searchFilters['emotion'] != 'all') {
        if (dream['mood'] != _searchFilters['emotion']) return false;
      }

      if (_searchFilters['symbols'] != null &&
          (_searchFilters['symbols'] as List).isNotEmpty) {
        final dreamSymbols = dream['ai_symbols'] as List? ?? [];
        final filterSymbols = _searchFilters['symbols'] as List;
        final hasMatch =
            filterSymbols.any((symbol) => dreamSymbols.contains(symbol));
        if (!hasMatch) return false;
      }
    }

    return true;
  }

  /// Show notification for new dream
  void _showNewDreamNotification(Map<String, dynamic> dream) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications_active,
                color: AppTheme.coralRed, size: 20),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'New dream: ${dream['title'] ?? 'Untitled'}',
                style: TextStyle(color: AppTheme.textWhite),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.cardDarkBurgundy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          textColor: AppTheme.coralRed,
          onPressed: () => _handleDreamTap(dream),
        ),
      ),
    );
  }

  /// Invalidate cache to force refresh on next load
  void _invalidateCache() {
    final cacheKey = DreamCacheService.generateCacheKey(
      category: _selectedCategory,
      sortOption: _selectedSortOption,
      searchText: _searchController.text,
      filters: _searchFilters,
    );
    DreamCacheService.invalidateCache(cacheKey);
  }

  Future<void> _loadDreams({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 0;
        _dreams.clear();
        _hasMore = true;
      }
    });

    try {
      // Generate cache key
      final cacheKey = DreamCacheService.generateCacheKey(
        category: _selectedCategory,
        sortOption: _selectedSortOption,
        searchText: _searchController.text,
        filters: _searchFilters,
      );

      // Try to get from cache first
      if (_currentPage == 0 && !refresh) {
        final cachedDreams = await DreamCacheService.getCachedDreams(cacheKey);
        if (cachedDreams != null && cachedDreams.isNotEmpty) {
          setState(() {
            _dreams = cachedDreams;
            _isLoading = false;
          });
          return;
        }
      }

      // Fetch from server
      final result = await _dreamService.getPublicDreamsPaginated(
        page: _currentPage,
        pageSize: _pageSize,
        category: _selectedCategory != 'all' ? _selectedCategory : null,
        sortOption: _selectedSortOption,
        searchText:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        advancedFilters: _searchFilters.isNotEmpty ? _searchFilters : null,
      );

      final newDreams = result['dreams'] as List<Map<String, dynamic>>;
      final hasMore = result['hasMore'] as bool;

      setState(() {
        if (refresh) {
          _dreams = newDreams;
        } else {
          _dreams.addAll(newDreams);
        }
        _hasMore = hasMore;
        _currentPage++;
        _isLoading = false;
      });

      // Cache the first page
      if (_currentPage == 1) {
        await DreamCacheService.cacheDreams(cacheKey, _dreams);
      }
    } catch (e) {
      print('Failed to load dreams: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadDreams();
    }
  }

  Future<void> _trackFeedView() async {
    await AnalyticsService.trackFeedView();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();

    // Clean up real-time subscriptions
    if (_dreamsChannel != null) {
      _dreamService.unsubscribeFromRealtimeUpdates('public-dreams-feed');
    }
    if (_engagementChannel != null) {
      _dreamService.unsubscribeFromRealtimeUpdates('engagement-metrics');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.createGradientBackground(),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              // Show real-time connection status
              if (_isRealtimeConnected) _buildRealtimeIndicator(),
              CategoryTabsWidget(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _loadDreams(refresh: true);
                },
              ),
              SortOptionsWidget(
                selectedSortOption: _selectedSortOption,
                onSortOptionSelected: (option) {
                  setState(() {
                    _selectedSortOption = option;
                  });
                  _loadDreams(refresh: true);
                },
              ),
              if (_showFilterPanel) _buildFilterPanel(),
              Expanded(
                child: _isInitialLoad
                    ? _buildLoadingIndicator()
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: AppTheme.coralRed,
                        backgroundColor: AppTheme.cardDarkBurgundy,
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            if (_aiRecommendations.isNotEmpty)
                              SliverToBoxAdapter(
                                child: AIRecommendationsWidget(
                                  recommendations: _aiRecommendations,
                                  onRecommendationTap: _handleRecommendationTap,
                                ),
                              ),
                            if (_trendingDreams.isNotEmpty)
                              SliverToBoxAdapter(
                                child: TrendingSectionWidget(
                                  trendingDreams: _trendingDreams,
                                  onDreamTap: _handleDreamTap,
                                ),
                              ),
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                              sliver: _dreams.isEmpty
                                  ? SliverToBoxAdapter(
                                      child: _buildEmptyState(),
                                    )
                                  : SliverList(
                                      delegate: SliverChildBuilderDelegate((
                                        context,
                                        index,
                                      ) {
                                        if (index < _dreams.length) {
                                          final dream = _dreams[index];
                                          return FeedDreamCardWidget(
                                            dream: dream,
                                            onTap: () => _handleDreamTap(dream),
                                            onResonance: () =>
                                                _handleResonance(dream['id']),
                                            onReport: () =>
                                                _handleReport(dream['id']),
                                          );
                                        }
                                        return null;
                                      }, childCount: _dreams.length),
                                    ),
                            ),
                            if (_isLoading)
                              SliverToBoxAdapter(child: _buildLoadingMore()),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build real-time connection indicator
  Widget _buildRealtimeIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: AppTheme.cardDarkBurgundy.withAlpha(128),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.coralRed,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'Live Updates Active',
            style: TextStyle(
              color: AppTheme.textMediumGray,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.coralRed),
          SizedBox(height: 2.h),
          Text(
            'Loading dreams...',
            style: TextStyle(color: AppTheme.textLightGray, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Container(
      padding: EdgeInsets.all(2.h),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: AppTheme.coralRed,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 60,
            color: AppTheme.textDisabledGray,
          ),
          SizedBox(height: 2.h),
          Text(
            'No dreams found',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your filters or search criteria',
            style: TextStyle(color: AppTheme.textMediumGray, fontSize: 13.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryBurgundy.withAlpha(230),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderPurple.withAlpha(128),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dream Feed',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _showAdvancedSearch
                          ? AppTheme.coralRed
                          : AppTheme.textWhite,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _showAdvancedSearch = true;
                      });
                      _showAdvancedSearchModal();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _showFilterPanel
                          ? Icons.filter_list
                          : Icons.filter_list_outlined,
                      color: _showFilterPanel
                          ? AppTheme.coralRed
                          : AppTheme.textWhite,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _showFilterPanel = !_showFilterPanel;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
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
              controller: _searchController,
              style: TextStyle(color: AppTheme.textWhite, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Search dreams, symbols, emotions...',
                hintStyle: TextStyle(
                  color: AppTheme.textDisabledGray,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.textMediumGray,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppTheme.textMediumGray,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return SymbolFilterWidget(
      selectedFilter: _selectedFilter,
      onFilterSelected: (filter) {
        setState(() {
          _selectedFilter = filter;
        });
        _handleSymbolFilter(filter);
      },
    );
  }

  void _showAdvancedSearchModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AdvancedSearchWidget(
        onSearchFiltersChanged: (filters) {
          setState(() {
            _searchFilters = filters;
            _showAdvancedSearch = false;
          });
          _loadDreams(refresh: true);
        },
        onClose: () {
          setState(() {
            _showAdvancedSearch = false;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleRecommendationTap(Map<String, dynamic> recommendation) {
    _handleDreamTap(recommendation);
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _loadTrendingDreams(),
      _loadAIRecommendations(),
      _loadDreams(refresh: true),
    ]);
  }

  void _handleDreamTap(Map<String, dynamic> dream) {
    _handleDreamCardTap(dream);
  }

  void _handleDreamCardTap(Map<String, dynamic> dream) {
    AnalyticsService.trackFeedDreamViewed(
      dreamId: dream['id'] ?? '',
      dreamTitle: dream['title'] ?? 'Untitled Dream',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDreamDetailSheet(dream),
    );
  }

  void _handleSymbolFilter(String symbol) {
    setState(() {
      _selectedFilter = symbol;
    });
    _loadDreams(refresh: true);

    AnalyticsService.trackSymbolFilter(
      symbol: symbol,
      resultsCount: _dreams.length,
    );
  }

  Widget _buildDreamDetailSheet(Map<String, dynamic> dream) {
    return Container(
      height: 80.h,
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
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.textDisabledGray,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.accentRedPurple,
                        radius: 20,
                        child: Text(
                          dream['username'][0],
                          style: TextStyle(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dream['username'],
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            dream['timestamp'],
                            style: TextStyle(
                              color: AppTheme.textDisabledGray,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    dream['title'],
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    dream['fullContent'],
                    style: TextStyle(
                      color: AppTheme.textLightGray,
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: dream['symbols'].map<Widget>((symbol) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardMediumPurple,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: AppTheme.accentRedPurple.withAlpha(128),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '#$symbol',
                          style: TextStyle(
                            color: AppTheme.accentRedPurple,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.cardMediumPurple,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppTheme.borderPurple.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.visibility_outlined,
                          '${dream['views']}',
                          'Views',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.borderPurple.withAlpha(77),
                        ),
                        _buildStatItem(
                          Icons.favorite_outline,
                          '${dream['resonance']}',
                          'Resonance',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.borderPurple.withAlpha(77),
                        ),
                        _buildStatItem(
                          Icons.emoji_emotions_outlined,
                          dream['emotion'],
                          'Emotion',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.coralRed, size: 24),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppTheme.textMediumGray, fontSize: 11.sp),
        ),
      ],
    );
  }

  void _handleResonance(String dreamId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to resonance'),
        backgroundColor: AppTheme.cardDarkBurgundy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleReport(String dreamId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkBurgundy,
        title: Text(
          'Report Dream',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        content: Text(
          'Are you sure you want to report this dream as inappropriate?',
          style: TextStyle(color: AppTheme.textLightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMediumGray),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dream reported'),
                  backgroundColor: AppTheme.cardDarkBurgundy,
                ),
              );
            },
            child: Text('Report', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}

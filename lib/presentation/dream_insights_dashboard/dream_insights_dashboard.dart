import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_constants.dart';
import '../../providers/dream_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/dream_service.dart';
import '../../theme/app_theme.dart';

class DreamInsightsDashboard extends StatefulWidget {
  const DreamInsightsDashboard({Key? key}) : super(key: key);

  @override
  State<DreamInsightsDashboard> createState() => _DreamInsightsDashboardState();
}

class _DreamInsightsDashboardState extends State<DreamInsightsDashboard> {
  final DreamService _dreamService = DreamService();
  int _selectedTimeRange = 30; // days
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _insights = [];
  bool _isLoading = false;
  String? _currentInsight;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final dreamProvider = context.read<DreamProvider>();
      await dreamProvider.loadStatistics();
      await dreamProvider.loadInsights(limit: 10);

      final stats = await _dreamService.getDreamStatistics();
      final insights = await _dreamService.getUserInsights(limit: 10);

      setState(() {
        _statistics = stats;
        _insights = insights;
      });
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateAIInsight(String insightType) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentInsight = null;
    });

    try {
      final insight = await _dreamService.generateDreamInsights(
        insightType: insightType,
        dreamCount: 15,
      );

      await AnalyticsService.trackInsightGeneration(
        insightType: insightType,
        confidence: 0.85,
      );

      await _dreamService.saveInsight(
        insightType: insightType,
        title: _getInsightTitle(insightType),
        content: insight,
      );

      setState(() => _currentInsight = insight);
      _loadDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating insight: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getInsightTitle(String insightType) {
    switch (insightType) {
      case 'patterns':
        return 'Dream Pattern Analysis';
      case 'emotions':
        return 'Emotional Journey Insights';
      case 'symbols':
        return 'Symbol Meaning Analysis';
      case 'themes':
        return 'Life Theme Insights';
      default:
        return 'Dream Insights';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDarkest,
      body: Container(
        decoration: AppTheme.createGradientBackground(),
        child: SafeArea(
          child: _isLoading && _statistics.isEmpty
              ? _buildLoadingState()
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  color: AppTheme.primaryPurple,
                  backgroundColor: AppTheme.cardBackground,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header
                      SliverToBoxAdapter(child: _buildHeader()),

                      // Time Range Selector
                      SliverToBoxAdapter(child: _buildTimeRangeSelector()),

                      // Dream Personality Card
                      SliverToBoxAdapter(child: _buildDreamPersonalityCard()),

                      // Stats Grid
                      SliverToBoxAdapter(child: _buildStatsGrid()),

                      // Theme Frequency
                      SliverToBoxAdapter(child: _buildThemeFrequencySection()),

                      // Recurring Elements
                      SliverToBoxAdapter(child: _buildRecurringElementsSection()),

                      // AI Insights Section
                      SliverToBoxAdapter(child: _buildAIInsightsSection()),

                      // Current Insight
                      if (_currentInsight != null)
                        SliverToBoxAdapter(child: _buildCurrentInsightCard()),

                      // Recent Insights
                      SliverToBoxAdapter(child: _buildRecentInsightsSection()),

                      // Bottom Padding
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryPurple),
          const SizedBox(height: 16),
          Text(
            'Loading insights...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.featureInsights,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Discover patterns in your dreams',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _loadDashboardData,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.refresh,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          children: AppConstants.timeRanges.map((range) {
            final isSelected = _selectedTimeRange == range['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedTimeRange = range['value'] as int);
                  _loadDashboardData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    range['label'] as String,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected ? AppTheme.textWhite : AppTheme.textMuted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDreamPersonalityCard() {
    final dreamProvider = context.watch<DreamProvider>();
    final totalDreams = dreamProvider.dreamCount;
    final lucidDreams = dreamProvider.lucidDreams.length;
    final avgClarity = dreamProvider.averageClarityScore;

    // Determine dream personality type based on patterns
    String personalityType = 'Explorer';
    String personalityDesc = 'Your dreams are vivid and varied';
    IconData personalityIcon = Icons.explore;
    Color personalityColor = AppTheme.secondaryTeal;

    if (lucidDreams > totalDreams * 0.3) {
      personalityType = 'Lucid Dreamer';
      personalityDesc = 'You have strong dream awareness';
      personalityIcon = Icons.visibility;
      personalityColor = AppTheme.primaryPurple;
    } else if (avgClarity > 7) {
      personalityType = 'Vivid Visualizer';
      personalityDesc = 'Your dreams are crystal clear';
      personalityIcon = Icons.palette;
      personalityColor = AppTheme.tertiaryOrange;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              personalityColor.withOpacity(0.2),
              AppTheme.cardBackground,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: personalityColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: personalityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                personalityIcon,
                color: personalityColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dream Personality',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    personalityType,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: personalityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    personalityDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final dreamProvider = context.watch<DreamProvider>();
    final totalDreams = dreamProvider.dreamCount;
    final lucidDreams = dreamProvider.lucidDreams.length;
    final avgClarity = dreamProvider.averageClarityScore;
    final streak = _calculateStreak(dreamProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Dreams',
                  value: '$totalDreams',
                  icon: Icons.auto_stories,
                  color: AppTheme.primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Lucid Dreams',
                  value: '$lucidDreams',
                  subtitle: '${totalDreams > 0 ? ((lucidDreams / totalDreams) * 100).toStringAsFixed(0) : 0}%',
                  icon: Icons.stars,
                  color: AppTheme.accentPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Avg. Clarity',
                  value: avgClarity.toStringAsFixed(1),
                  subtitle: 'out of 10',
                  icon: Icons.visibility,
                  color: AppTheme.secondaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Streak',
                  value: '$streak',
                  subtitle: 'days',
                  icon: Icons.local_fire_department,
                  color: AppTheme.tertiaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.createStatCardDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeFrequencySection() {
    final dreamProvider = context.watch<DreamProvider>();

    // Extract themes from all dreams
    final Map<String, int> themeCounts = {};
    for (final dream in dreamProvider.dreams) {
      for (final theme in dream.aiThemes) {
        themeCounts[theme] = (themeCounts[theme] ?? 0) + 1;
      }
    }

    final sortedThemes = themeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topThemes = sortedThemes.take(5).toList();

    if (topThemes.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = topThemes.first.value;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppTheme.secondaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Theme Frequency',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.createCardDecoration(),
            child: Column(
              children: topThemes.asMap().entries.map((entry) {
                final theme = entry.value;
                final progress = theme.value / maxCount;
                final colors = [
                  AppTheme.primaryPurple,
                  AppTheme.secondaryTeal,
                  AppTheme.tertiaryOrange,
                  AppTheme.accentPink,
                  AppTheme.accentGreen,
                ];
                final color = colors[entry.key % colors.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            theme.key,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${theme.value}x',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: color.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringElementsSection() {
    final dreamProvider = context.watch<DreamProvider>();

    // Extract symbols and emotions
    final Map<String, int> symbolCounts = {};
    final Map<String, int> emotionCounts = {};

    for (final dream in dreamProvider.dreams) {
      for (final symbol in dream.aiSymbols) {
        symbolCounts[symbol] = (symbolCounts[symbol] ?? 0) + 1;
      }
      for (final emotion in dream.aiEmotions) {
        emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
      }
    }

    final topSymbols = symbolCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (topSymbols.isEmpty && topEmotions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.repeat, color: AppTheme.accentPink, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recurring Elements',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symbols
              if (topSymbols.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.createCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.category, color: AppTheme.primaryPurple, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Symbols',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: topSymbols.take(5).map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                s.key,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              if (topSymbols.isNotEmpty && topEmotions.isNotEmpty)
                const SizedBox(width: 12),
              // Emotions
              if (topEmotions.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.createCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: AppTheme.tertiaryOrange, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Emotions',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppTheme.tertiaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: topEmotions.take(5).map((e) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.tertiaryOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                e.key,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.tertiaryOrange,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.createAccentGradient(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppTheme.textWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Dream Analysis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Generate personalized insights',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildInsightButton(
                type: 'patterns',
                label: 'Patterns',
                icon: Icons.grain,
                color: AppTheme.primaryPurple,
              ),
              _buildInsightButton(
                type: 'emotions',
                label: 'Emotions',
                icon: Icons.favorite,
                color: AppTheme.tertiaryOrange,
              ),
              _buildInsightButton(
                type: 'symbols',
                label: 'Symbols',
                icon: Icons.auto_awesome,
                color: AppTheme.secondaryTeal,
              ),
              _buildInsightButton(
                type: 'themes',
                label: 'Themes',
                icon: Icons.lightbulb,
                color: AppTheme.accentPink,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightButton({
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _generateAIInsight(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentInsightCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withOpacity(0.2),
              AppTheme.cardBackground,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.textWhite,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest AI Insight',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Generated just now',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDarkest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentInsight!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentInsightsSection() {
    if (_insights.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: AppTheme.createCardDecoration(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  size: 48,
                  color: AppTheme.primaryPurple,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No insights yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate your first AI insight above to discover patterns in your dreams',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Insights',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_insights.length} total',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_insights.take(3).map((insight) => _buildInsightItem(insight))),
        ],
      ),
    );
  }

  Widget _buildInsightItem(Map<String, dynamic> insight) {
    final type = insight['insight_type'] ?? '';
    final color = _getInsightTypeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.createCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getInsightTypeIcon(type),
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  insight['insight_title'] ?? 'Insight',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatDate(insight['date_generated']),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight['insight_content'] ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  int _calculateStreak(DreamProvider dreamProvider) {
    final dreams = dreamProvider.dreams;
    if (dreams.isEmpty) return 0;

    final sortedDreams = List.from(dreams)
      ..sort((a, b) => b.dreamDate.compareTo(a.dreamDate));

    int streak = 0;
    DateTime? lastDate;

    for (final dream in sortedDreams) {
      final dreamDate = DateTime(
        dream.dreamDate.year,
        dream.dreamDate.month,
        dream.dreamDate.day,
      );

      if (lastDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        if (todayDate.difference(dreamDate).inDays <= 1) {
          streak = 1;
          lastDate = dreamDate;
        } else {
          break;
        }
      } else {
        if (lastDate.difference(dreamDate).inDays == 1) {
          streak++;
          lastDate = dreamDate;
        } else if (lastDate.difference(dreamDate).inDays > 1) {
          break;
        }
      }
    }

    return streak;
  }

  Color _getInsightTypeColor(String type) {
    switch (type) {
      case 'patterns':
        return AppTheme.primaryPurple;
      case 'emotions':
        return AppTheme.tertiaryOrange;
      case 'symbols':
        return AppTheme.secondaryTeal;
      case 'themes':
        return AppTheme.accentPink;
      default:
        return AppTheme.primaryPurple;
    }
  }

  IconData _getInsightTypeIcon(String type) {
    switch (type) {
      case 'patterns':
        return Icons.grain;
      case 'emotions':
        return Icons.favorite;
      case 'symbols':
        return Icons.auto_awesome;
      case 'themes':
        return Icons.lightbulb;
      default:
        return Icons.psychology;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date).inDays;

      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      if (diff < 7) return '${diff}d ago';

      return '${date.day}/${date.month}';
    } catch (e) {
      return '';
    }
  }
}

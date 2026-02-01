import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/dream_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/dream_service.dart';
import '../../theme/app_theme.dart';
import './widgets/dream_category_chart_widget.dart';
import './widgets/dream_frequency_chart_widget.dart';
import './widgets/insight_card_widget.dart';
import './widgets/mood_correlation_chart_widget.dart';
import './widgets/streak_analysis_widget.dart';
import './widgets/time_range_selector_widget.dart';

class DreamInsightsDashboard extends StatefulWidget {
  const DreamInsightsDashboard({Key? key}) : super(key: key);

  @override
  State<DreamInsightsDashboard> createState() => _DreamInsightsDashboardState();
}

class _DreamInsightsDashboardState extends State<DreamInsightsDashboard> {
  final DreamService _dreamService = DreamService();
  String selectedTimeRange = 'Last 30 days';
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Load dream statistics and insights
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

      // Track insight generation
      await AnalyticsService.trackInsightGeneration(
        insightType: insightType,
        confidence: 0.85,
      );

      // Save the generated insight
      await _dreamService.saveInsight(
        insightType: insightType,
        title: _getInsightTitle(insightType),
        content: insight,
      );

      setState(() {
        _currentInsight = insight;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_getInsightTitle(insightType)} generated successfully!',
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh insights list
      _loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating insight: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDarkPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Dream Insights',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.textWhite),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: AppTheme.textWhite),
            onPressed: _showInfoDialog,
            tooltip: 'About Insights',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentPurple),
                  SizedBox(height: 2.h),
                  Text(
                    'Generating AI insights...',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMediumGray,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: AppTheme.accentPurple,
              backgroundColor: AppTheme.cardDarkPurple,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Range Selector
                    TimeRangeSelectorWidget(
                      selectedRange: selectedTimeRange,
                      onRangeChanged: (range) {
                        setState(() {
                          selectedTimeRange = range;
                        });
                        _loadDashboardData();
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Quick Stats Overview
                    _buildQuickStatsSection(),

                    SizedBox(height: 2.h),

                    // AI Insights Generation Section
                    _buildAIInsightsSection(),

                    SizedBox(height: 2.h),

                    // Current AI Insight Display
                    if (_currentInsight != null) _buildCurrentInsightCard(),

                    SizedBox(height: 2.h),

                    // Dream Analytics Charts
                    _buildChartsSection(),

                    SizedBox(height: 2.h),

                    // Recent Insights History
                    _buildRecentInsightsSection(),

                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickStatsSection() {
    final totalDreams = (_statistics['total_dreams'] ?? 0) as int;
    final lucidDreams = (_statistics['lucid_dreams'] ?? 0) as int;
    final avgClarity = _statistics['avg_clarity_score']?.toDouble() ?? 0.0;
    final dreamStreak = (_statistics['current_streak'] ?? 0) as int;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InsightCardWidget(
                title: 'Total Dreams',
                value: totalDreams.toString(),
                subtitle: 'Recorded dreams',
                cardColor: AppTheme.cardDarkPurple,
              ),
            ),
            Expanded(
              child: InsightCardWidget(
                title: 'Lucid Dreams',
                value: lucidDreams.toString(),
                subtitle:
                    '${((lucidDreams / max(totalDreams, 1)) * 100).toStringAsFixed(1)}% lucid rate',
                cardColor: AppTheme.cardDarkPurple,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: InsightCardWidget(
                title: 'Avg Clarity',
                value: avgClarity.toStringAsFixed(1),
                subtitle: 'Out of 10',
                cardColor: AppTheme.cardDarkPurple,
              ),
            ),
            Expanded(
              child: InsightCardWidget(
                title: 'Dream Streak',
                value: dreamStreak.toString(),
                subtitle: 'Days in a row',
                cardColor: AppTheme.cardDarkPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAIInsightsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardDarkPurple,
            AppTheme.cardDarkPurple.withAlpha(230),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentPurpleLight.withAlpha(77),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPurple.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.psychology,
                  color: AppTheme.accentPurpleLight,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Dream Insights',
                      style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Powered by AI',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentPurpleLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            'Generate personalized insights from your dream patterns using advanced AI analysis',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLightGray,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 3.w,
            runSpacing: 2.h,
            children: [
              _buildInsightButton(
                'patterns',
                'Pattern Analysis',
                Icons.grain,
                'Discover recurring themes and symbols',
              ),
              _buildInsightButton(
                'emotions',
                'Emotional Journey',
                Icons.favorite,
                'Understand your emotional landscape',
              ),
              _buildInsightButton(
                'symbols',
                'Symbol Meanings',
                Icons.auto_awesome,
                'Decode your personal dream symbols',
              ),
              _buildInsightButton(
                'themes',
                'Life Theme Insights',
                Icons.lightbulb,
                'Connect dreams to life patterns',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightButton(
    String type,
    String label,
    IconData icon,
    String description,
  ) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _generateAIInsight(type),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentPurple,
          foregroundColor: AppTheme.textWhite,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 5.w),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textWhite.withAlpha(204),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentInsightCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentPurple.withAlpha(26),
            AppTheme.cardDarkPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentPurpleLight.withAlpha(128),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppTheme.textWhite,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest AI Insight',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Generated just now',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentPurpleLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDarkest.withAlpha(128),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentInsight!,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLightGray,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Dream Analytics',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: DreamFrequencyChartWidget(timeRange: selectedTimeRange),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: const MoodCorrelationChartWidget(),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: const DreamCategoryChartWidget(),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: const StreakAnalysisWidget(),
        ),
      ],
    );
  }

  Widget _buildRecentInsightsSection() {
    if (_insights.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.cardDarkPurple.withAlpha(128),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderPurple.withAlpha(128),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withAlpha(26),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.psychology_outlined,
                size: 12.w,
                color: AppTheme.accentPurpleLight,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'No insights generated yet',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Generate your first AI insight above to start discovering patterns in your dreams using advanced OpenAI analysis',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Insights',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_insights.length} total',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentPurpleLight,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _insights.length,
          itemBuilder: (context, index) {
            final insight = _insights[index];
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.cardDarkPurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderPurple.withAlpha(128),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: _getInsightTypeColor(
                            insight['insight_type'] ?? '',
                          ).withAlpha(51),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getInsightTypeIcon(insight['insight_type'] ?? ''),
                          color: _getInsightTypeColor(
                            insight['insight_type'] ?? '',
                          ),
                          size: 4.w,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          insight['insight_title'] ?? 'Insight',
                          style: AppTheme.darkTheme.textTheme.titleSmall
                              ?.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(
                        _formatDate(insight['date_generated']),
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMediumGray,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    insight['insight_content'] ?? '',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLightGray,
                      height: 1.4,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getInsightTypeColor(
                        insight['insight_type'] ?? '',
                      ).withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatInsightType(insight['insight_type'] ?? ''),
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: _getInsightTypeColor(
                          insight['insight_type'] ?? '',
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getInsightTypeColor(String type) {
    switch (type) {
      case 'patterns':
        return AppTheme.accentPurple;
      case 'emotions':
        return AppTheme.warningColor;
      case 'symbols':
        return AppTheme.successColor;
      case 'themes':
        return AppTheme.accentPurpleLight;
      default:
        return AppTheme.accentPurple;
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

  String _formatInsightType(String type) {
    switch (type) {
      case 'patterns':
        return 'Pattern Analysis';
      case 'emotions':
        return 'Emotional Journey';
      case 'symbols':
        return 'Symbol Meanings';
      case 'themes':
        return 'Life Themes';
      default:
        return 'General Insight';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '${difference}d ago';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDarkPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.psychology, color: AppTheme.accentPurpleLight),
            SizedBox(width: 2.w),
            Text(
              'About Dream Insights',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your dream insights are generated using advanced AI, analyzing your recorded dreams to uncover patterns, symbols, and themes.',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLightGray,
                height: 1.4,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Features:',
              style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            _buildFeatureItem(
              'Pattern Analysis',
              'Identify recurring themes and symbols',
            ),
            _buildFeatureItem(
              'Emotional Journey',
              'Track your emotional landscape',
            ),
            _buildFeatureItem(
              'Symbol Meanings',
              'Decode personal dream symbols',
            ),
            _buildFeatureItem('Life Themes', 'Connect dreams to life patterns'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: TextStyle(color: AppTheme.accentPurpleLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 1.w,
            height: 1.w,
            margin: EdgeInsets.only(top: 1.5.h, right: 2.w),
            decoration: BoxDecoration(
              color: AppTheme.accentPurpleLight,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentPurpleLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

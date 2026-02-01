import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_constants.dart';
import '../../core/app_export.dart';
import '../../models/dream.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dream_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../theme/app_theme.dart';
import './widgets/dream_card_widget.dart';
import './widgets/empty_state_widget.dart';

class DreamJournalHome extends StatefulWidget {
  const DreamJournalHome({super.key});

  @override
  State<DreamJournalHome> createState() => _DreamJournalHomeState();
}

class _DreamJournalHomeState extends State<DreamJournalHome>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: AppConstants.animationNormal,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dreamProvider = context.read<DreamProvider>();
      if (!dreamProvider.hasDreams) {
        dreamProvider.loadDreams();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDarkest,
      body: Container(
        decoration: AppTheme.createGradientBackground(),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer3<AuthProvider, DreamProvider, SleepProvider>(
              builder: (context, auth, dreamProvider, sleepProvider, _) {
                if (dreamProvider.isLoading && dreamProvider.dreams.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryPurple,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => dreamProvider.loadDreams(),
                  color: AppTheme.primaryPurple,
                  backgroundColor: AppTheme.cardBackground,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header with Branding
                      SliverToBoxAdapter(
                        child: _buildHeader(auth),
                      ),

                      // Stats Dashboard
                      SliverToBoxAdapter(
                        child: _buildStatsDashboard(dreamProvider, sleepProvider),
                      ),

                      // Quick Capture Button
                      SliverToBoxAdapter(
                        child: _buildQuickCaptureSection(),
                      ),

                      // Recent Dreams Section
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(
                          AppConstants.sectionRecentDreams,
                          dreamProvider.dreams.length,
                          onViewAll: () {
                            Navigator.pushNamed(context, AppRoutes.calendarView);
                          },
                        ),
                      ),

                      // Dreams List or Empty State
                      dreamProvider.dreams.isEmpty
                          ? SliverFillRemaining(
                              child: EmptyStateWidget(
                                onGetStarted: () => _navigateToDreamCapture(),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final dream = dreamProvider.dreams[index];
                                  return _buildDreamTimelineCard(dream, dreamProvider);
                                },
                                childCount: dreamProvider.dreams.length > 5
                                    ? 5
                                    : dreamProvider.dreams.length,
                              ),
                            ),

                      // View All Button (if more dreams)
                      if (dreamProvider.dreams.length > 5)
                        SliverToBoxAdapter(
                          child: _buildViewAllButton(dreamProvider.dreams.length),
                        ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: _buildRecordFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Branding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: AppTheme.createAccentGradient(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.nightlight_round,
                          color: AppTheme.textWhite,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            AppConstants.appSubtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    onPressed: () {
                      // TODO: Implement search
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.settingsAndProfile);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Greeting
          Text(
            '${AppConstants.getGreeting()}, ${auth.displayName}! ${AppConstants.getGreetingEmoji()}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.appTagline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(DreamProvider dreamProvider, SleepProvider sleepProvider) {
    // Calculate stats
    final totalDreams = dreamProvider.dreamCount;
    final lucidDreams = dreamProvider.lucidDreams.length;
    final streak = _calculateStreak(dreamProvider.dreams);
    final avgClarity = dreamProvider.averageClarityScore;

    // Get recent sleep quality for "Rested" score
    final restedScore = _calculateRestedScore(sleepProvider);

    // Get recall vividness (average clarity as percentage)
    final recallVividness = avgClarity > 0 ? (avgClarity / 10 * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Top Row - Main Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: AppConstants.statRestedScore,
                  value: '$restedScore%',
                  subtitle: 'feeling refreshed',
                  icon: Icons.battery_charging_full,
                  color: AppTheme.accentGreen,
                  showCircularIndicator: true,
                  indicatorValue: restedScore / 100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: AppConstants.statRecallVividness,
                  value: '$recallVividness%',
                  subtitle: avgClarity > 7 ? 'Very vivid' : avgClarity > 4 ? 'Moderate' : 'Building...',
                  icon: Icons.visibility,
                  color: AppTheme.secondaryTeal,
                  showProgressBar: true,
                  progressValue: recallVividness / 100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom Row - Secondary Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: AppConstants.statLoggingStreak,
                  value: '$streak',
                  subtitle: streak == 1 ? 'day' : 'days',
                  icon: Icons.local_fire_department,
                  color: AppTheme.tertiaryOrange,
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: AppConstants.statTotalDreams,
                  value: '$totalDreams',
                  subtitle: 'recorded',
                  icon: Icons.auto_stories,
                  color: AppTheme.primaryPurple,
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: AppConstants.statLucidDreams,
                  value: '$lucidDreams',
                  subtitle: 'lucid',
                  icon: Icons.stars,
                  color: AppTheme.accentPink,
                  isCompact: true,
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
    required String subtitle,
    required IconData icon,
    required Color color,
    bool showCircularIndicator = false,
    bool showProgressBar = false,
    double indicatorValue = 0,
    double progressValue = 0,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: AppTheme.createStatCardDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: isCompact ? 18 : 20),
              if (showCircularIndicator)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: indicatorValue,
                        strokeWidth: 4,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: isCompact ? 8 : 12),
          if (!showCircularIndicator)
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (showProgressBar) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 6,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
          SizedBox(height: isCompact ? 4 : 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          if (!isCompact)
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSubtle,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickCaptureSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withOpacity(0.15),
              AppTheme.secondaryTeal.withOpacity(0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.featureVoiceCapture,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Capture your dream before it fades',
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToDreamCapture,
                    icon: const Icon(Icons.mic, size: 20),
                    label: const Text(AppConstants.buttonRecordDream),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: AppTheme.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.dreamEntryCreation);
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Write'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    side: BorderSide(
                      color: AppTheme.borderDefault,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(
                AppConstants.buttonViewAll,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDreamTimelineCard(Dream dream, DreamProvider dreamProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.createCardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Column
              Container(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      _formatDay(dream.dreamDate),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatMonth(dream.dreamDate),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Divider Line
              Container(
                width: 2,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.primaryPurple.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 16),
              // Dream Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dream.displayTitle,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (dream.isLucid)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '✨ Lucid',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.primaryPurple,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dream.content,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tags/Themes
                    if (dream.aiThemes.isNotEmpty || dream.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ...dream.aiThemes.take(2).map((theme) => _buildTag(theme, isAI: true)),
                          ...dream.tags.take(2).map((tag) => _buildTag(tag)),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, {bool isAI = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAI
            ? AppTheme.secondaryTeal.withOpacity(0.15)
            : AppTheme.cardBackgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAI
              ? AppTheme.secondaryTeal.withOpacity(0.3)
              : AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Text(
        '#$text',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isAI ? AppTheme.secondaryTeal : AppTheme.textMuted,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildViewAllButton(int totalCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.calendarView);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View all $totalCount dreams',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward,
              color: AppTheme.primaryPurple,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.createAccentGradient(),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _navigateToDreamCapture,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.mic, color: AppTheme.textWhite),
        label: Text(
          AppConstants.buttonRecordDream,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToDreamCapture() {
    Navigator.pushNamed(context, AppRoutes.dreamEntryCreation);
  }

  int _calculateStreak(List<Dream> dreams) {
    if (dreams.isEmpty) return 0;

    // Sort dreams by date descending
    final sortedDreams = List<Dream>.from(dreams)
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
        // Check if the most recent dream is from today or yesterday
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final difference = todayDate.difference(dreamDate).inDays;

        if (difference <= 1) {
          streak = 1;
          lastDate = dreamDate;
        } else {
          break;
        }
      } else {
        final difference = lastDate.difference(dreamDate).inDays;
        if (difference == 1) {
          streak++;
          lastDate = dreamDate;
        } else if (difference > 1) {
          break;
        }
      }
    }

    return streak;
  }

  int _calculateRestedScore(SleepProvider sleepProvider) {
    // Calculate based on recent sleep sessions
    // For now, use a default or calculate based on available data
    final sessions = sleepProvider.sleepSessions;
    if (sessions.isEmpty) return 75; // Default score

    // Calculate average quality from recent sessions
    final recentSessions = sessions.take(7).toList();
    int totalScore = 0;
    int count = 0;

    for (final session in recentSessions) {
      final quality = session['quality'] as String?;
      if (quality != null) {
        switch (quality.toLowerCase()) {
          case 'excellent':
            totalScore += 100;
            break;
          case 'good':
            totalScore += 80;
            break;
          case 'fair':
            totalScore += 60;
            break;
          case 'poor':
            totalScore += 40;
            break;
          case 'terrible':
            totalScore += 20;
            break;
          default:
            totalScore += 60;
        }
        count++;
      }
    }

    return count > 0 ? (totalScore / count).round() : 75;
  }

  String _formatDay(DateTime date) {
    return date.day.toString().padLeft(2, '0');
  }

  String _formatMonth(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }
}

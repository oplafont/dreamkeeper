import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_constants.dart';
import '../../core/app_export.dart';
import '../../models/dream.dart';
import '../../providers/dream_provider.dart';
import '../../theme/app_theme.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _showTimelineView = true; // Toggle between calendar and timeline

  @override
  void initState() {
    super.initState();
    _loadDreamsForMonth();
  }

  Future<void> _loadDreamsForMonth() async {
    final dreamProvider = context.read<DreamProvider>();
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    await dreamProvider.loadDreamsByDateRange(
      startDate: firstDay,
      endDate: lastDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDarkest,
      body: Container(
        decoration: AppTheme.createGradientBackground(),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // View Toggle
              _buildViewToggle(),

              // Content
              Expanded(
                child: Consumer<DreamProvider>(
                  builder: (context, dreamProvider, _) {
                    if (dreamProvider.isLoading && dreamProvider.dreams.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryPurple,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _loadDreamsForMonth,
                      color: AppTheme.primaryPurple,
                      backgroundColor: AppTheme.cardBackground,
                      child: _showTimelineView
                          ? _buildTimelineView(dreamProvider)
                          : _buildCalendarView(dreamProvider),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAddDreamFAB(),
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
                AppConstants.sectionDreamTimeline,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Explore your dream journey',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
              _loadDreamsForMonth();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.today,
                color: AppTheme.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
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
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showTimelineView = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _showTimelineView
                        ? AppTheme.primaryPurple
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.view_timeline,
                        size: 18,
                        color: _showTimelineView
                            ? AppTheme.textWhite
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Timeline',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _showTimelineView
                              ? AppTheme.textWhite
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showTimelineView = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_showTimelineView
                        ? AppTheme.primaryPurple
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: !_showTimelineView
                            ? AppTheme.textWhite
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calendar',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: !_showTimelineView
                              ? AppTheme.textWhite
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineView(DreamProvider dreamProvider) {
    final dreams = dreamProvider.dreams;

    if (dreams.isEmpty) {
      return _buildEmptyState();
    }

    // Group dreams by date
    final Map<String, List<Dream>> groupedDreams = {};
    for (final dream in dreams) {
      final dateKey = _formatDateKey(dream.dreamDate);
      groupedDreams.putIfAbsent(dateKey, () => []);
      groupedDreams[dateKey]!.add(dream);
    }

    final sortedKeys = groupedDreams.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final dateDreams = groupedDreams[dateKey]!;
        final date = dateDreams.first.dreamDate;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: index > 0 ? 24 : 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _formatDateHeader(date),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppTheme.borderSubtle,
                    ),
                  ),
                ],
              ),
            ),

            // Dreams for this date
            ...dateDreams.map((dream) => _buildTimelineDreamCard(dream, dreamProvider)),
          ],
        );
      },
    );
  }

  Widget _buildTimelineDreamCard(Dream dream, DreamProvider dreamProvider) {
    return GestureDetector(
      onTap: () async {
        dreamProvider.selectDream(dream);
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.dreamDetailView,
          arguments: dream.id,
        );
        if (result == true) {
          _loadDreamsForMonth();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dream.isLucid
                        ? AppTheme.primaryPurple
                        : AppTheme.secondaryTeal,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.cardBackground,
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (dream.isLucid
                            ? AppTheme.primaryPurple
                            : AppTheme.secondaryTeal),
                        AppTheme.borderSubtle,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Dream Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.createCardDecoration(
                  hasAccent: dream.isLucid,
                  accentColor: AppTheme.primaryPurple,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and badges
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: AppTheme.primaryPurple,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Lucid',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Content preview
                    Text(
                      dream.content,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Tags and themes
                    if (dream.aiThemes.isNotEmpty || dream.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...dream.aiThemes.take(3).map((theme) => _buildTag(theme, isAI: true)),
                          ...dream.tags.take(2).map((tag) => _buildTag(tag)),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // Meta info
                    Row(
                      children: [
                        if (dream.mood != null) ...[
                          Text(
                            dream.moodEmoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dream.mood!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (dream.clarityScore != null) ...[
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: AppTheme.secondaryTeal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dream.clarityScore}/10',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppTheme.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, {bool isAI = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAI
            ? AppTheme.secondaryTeal.withOpacity(0.15)
            : AppTheme.cardBackgroundElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAI
              ? AppTheme.secondaryTeal.withOpacity(0.3)
              : AppTheme.borderSubtle,
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

  Widget _buildCalendarView(DreamProvider dreamProvider) {
    return CustomScrollView(
      slivers: [
        // Month Navigation
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.createCardDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _navigateToPrevious,
                  icon: const Icon(Icons.chevron_left, color: AppTheme.primaryPurple),
                ),
                Text(
                  _getMonthYear(_focusedDay),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: _navigateToNext,
                  icon: const Icon(Icons.chevron_right, color: AppTheme.primaryPurple),
                ),
              ],
            ),
          ),
        ),

        // Calendar
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: AppTheme.createCardDecoration(),
            child: TableCalendar<Dream>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => dreamProvider.getDreamsForDate(day),
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
                _loadDreamsForMonth();
              },
              calendarStyle: CalendarStyle(
                defaultDecoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                weekendDecoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryPurple,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                outsideDecoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppTheme.textPrimary,
                ),
                weekendTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppTheme.textPrimary,
                ),
                selectedTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
                todayTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
                outsideTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: AppTheme.textSubtle,
                ),
                markersMaxCount: 3,
                markerDecoration: const BoxDecoration(
                  color: AppTheme.secondaryTeal,
                  shape: BoxShape.circle,
                ),
                markerMargin: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 4),
                markerSize: 6,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronVisible: false,
                rightChevronVisible: false,
                headerPadding: EdgeInsets.symmetric(vertical: 16),
                titleTextStyle: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: events.any((e) => e.isLucid)
                              ? AppTheme.primaryPurple
                              : AppTheme.secondaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Selected Day Dreams
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Dreams for ${_formatDateHeader(_selectedDay)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (dreamProvider.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Dreams List
        _buildSelectedDayDreams(dreamProvider),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSelectedDayDreams(DreamProvider dreamProvider) {
    final dreams = dreamProvider.getDreamsForDate(_selectedDay);

    if (dreams.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.createCardDecoration(),
          child: Column(
            children: [
              Icon(
                Icons.nightlight_round,
                size: 48,
                color: AppTheme.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'No dreams recorded',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Record a dream to see it here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dream = dreams[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: _buildDreamListItem(dream, dreamProvider),
          );
        },
        childCount: dreams.length,
      ),
    );
  }

  Widget _buildDreamListItem(Dream dream, DreamProvider dreamProvider) {
    return GestureDetector(
      onTap: () {
        dreamProvider.selectDream(dream);
        Navigator.pushNamed(
          context,
          AppRoutes.dreamDetailView,
          arguments: dream.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.createCardDecoration(),
        child: Row(
          children: [
            // Mood Emoji
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  dream.moodEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dream.displayTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dream.mood ?? 'No mood'} • Clarity: ${dream.clarityScore ?? '-'}/10',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories,
                size: 64,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Dream Timeline',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start recording dreams to build your personal timeline and discover patterns.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.dreamEntryCreation);
              },
              icon: const Icon(Icons.mic),
              label: const Text(AppConstants.buttonRecordDream),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: AppTheme.textWhite,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDreamFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.createAccentGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.dreamEntryCreation);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: AppTheme.textWhite),
      ),
    );
  }

  String _getMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _navigateToPrevious() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
    _loadDreamsForMonth();
  }

  void _navigateToNext() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
    _loadDreamsForMonth();
  }
}

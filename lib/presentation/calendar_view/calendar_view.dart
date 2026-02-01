import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDarkPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Dream Calendar',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.today, color: AppTheme.textWhite),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
              _loadDreamsForMonth();
            },
            tooltip: 'Go to Today',
          ),
        ],
      ),
      body: Consumer<DreamProvider>(
        builder: (context, dreamProvider, _) {
          if (dreamProvider.isLoading && dreamProvider.dreamsByDate.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.accentPurple),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadDreamsForMonth,
            color: AppTheme.accentPurple,
            backgroundColor: AppTheme.cardDarkPurple,
            child: CustomScrollView(
              slivers: [
                // Current Month Display
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(4.w),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDarkPurple,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderPurple.withAlpha(128),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getMonthYear(_focusedDay),
                          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _navigateToPrevious,
                              icon: Icon(
                                Icons.chevron_left,
                                color: AppTheme.accentPurpleLight,
                              ),
                            ),
                            IconButton(
                              onPressed: _navigateToNext,
                              icon: Icon(
                                Icons.chevron_right,
                                color: AppTheme.accentPurpleLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Calendar
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDarkPurple,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.borderPurple.withAlpha(128),
                        width: 1,
                      ),
                    ),
                    child: TableCalendar<Dream>(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      eventLoader: (day) => dreamProvider.getDreamsForDate(day),
                      onDaySelected: _onDaySelected,
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
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
                        selectedDecoration: BoxDecoration(
                          color: AppTheme.accentPurple,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppTheme.accentPurpleLight.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                        outsideDecoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        weekendTextStyle: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        selectedTextStyle: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        todayTextStyle: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        outsideTextStyle: TextStyle(
                          color: AppTheme.textDisabledGray,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        markersMaxCount: 3,
                        markerDecoration: BoxDecoration(
                          color: AppTheme.successColor,
                          shape: BoxShape.circle,
                        ),
                        markerMargin: const EdgeInsets.symmetric(
                          horizontal: 0.5,
                          vertical: 4,
                        ),
                        markerSize: 6,
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        leftChevronVisible: false,
                        rightChevronVisible: false,
                        headerPadding: EdgeInsets.symmetric(vertical: 1.h),
                        titleTextStyle: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        weekendStyle: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 12.sp,
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
                                  color: AppTheme.successColor,
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

                SliverToBoxAdapter(child: SizedBox(height: 3.h)),

                // Selected Day Dreams Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dreams for ${_formatDate(_selectedDay)}',
                          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
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

                SliverToBoxAdapter(child: SizedBox(height: 1.h)),

                // Dreams List
                _buildDreamsList(dreamProvider),

                // Bottom padding
                SliverToBoxAdapter(child: SizedBox(height: 10.h)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDreamsList(DreamProvider dreamProvider) {
    final dreams = dreamProvider.getDreamsForDate(_selectedDay);

    if (dreams.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.cardDarkPurple,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderPurple.withAlpha(128),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.bedtime,
                size: 48,
                color: AppTheme.textMediumGray,
              ),
              SizedBox(height: 2.h),
              Text(
                'No dreams recorded',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Record a dream to see it here',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumGray,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.dreamEntryCreation);
                },
                icon: const Icon(Icons.add),
                label: const Text('Record Dream'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: AppTheme.textWhite,
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
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.cardDarkPurple,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderPurple.withAlpha(128),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    dream.moodEmoji,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
              ),
              title: Text(
                dream.displayTitle,
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${dream.mood ?? 'No mood'} • Clarity: ${dream.clarityScore ?? '-'}/10',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumGray,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textMediumGray,
                size: 16,
              ),
              onTap: () {
                dreamProvider.selectDream(dream);
                Navigator.pushNamed(
                  context,
                  AppRoutes.dreamDetailView,
                  arguments: dream.id,
                );
              },
            ),
          );
        },
        childCount: dreams.length,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

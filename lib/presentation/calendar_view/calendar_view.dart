import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_export.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _searchQuery = '';
  bool _isLoading = true;

  // Simplified mock data
  final Map<DateTime, List<Map<String, dynamic>>> _mockDreamData = {
    DateTime.now().subtract(const Duration(days: 1)): [
      {'id': '1', 'title': 'Flying Dream', 'mood': 'Happy', 'quality': 4},
    ],
    DateTime.now().subtract(const Duration(days: 3)): [
      {'id': '2', 'title': 'Adventure Dream', 'mood': 'Excited', 'quality': 5},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadDreams();
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
            },
            tooltip: 'Go to Today',
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
                              style: AppTheme.darkTheme.textTheme.titleLarge
                                  ?.copyWith(
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

                    // Simplified Calendar
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
                        child: TableCalendar<Map<String, dynamic>>(
                          firstDay: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDay: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          focusedDay: _focusedDay,
                          selectedDayPredicate:
                              (day) => isSameDay(_selectedDay, day),
                          eventLoader: _getMockDreamsForDate,
                          onDaySelected: _onDaySelected,
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          },
                          calendarStyle: CalendarStyle(
                            // Background colors
                            defaultDecoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            weekendDecoration: BoxDecoration(
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
                            outsideDecoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            // Text styles with clear white text
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
                            // Markers
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

                    // Selected Day Dreams - Simplified
                    ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'Dreams for ${_formatDate(_selectedDay)}',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.textWhite,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 1.h)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final mockDreams = _getMockDreamsForDate(
                            _selectedDay,
                          );
                          if (mockDreams.isEmpty) {
                            return Container(
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
                                    style: AppTheme
                                        .darkTheme
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: AppTheme.textWhite),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'Tap + to record your first dream',
                                    style: AppTheme
                                        .darkTheme
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textMediumGray,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          final dreamData = mockDreams[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
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
                                child: Icon(
                                  Icons.nights_stay,
                                  color: AppTheme.accentPurpleLight,
                                ),
                              ),
                              title: Text(
                                dreamData['title'] as String,
                                style: AppTheme.darkTheme.textTheme.titleSmall
                                    ?.copyWith(
                                      color: AppTheme.textWhite,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              subtitle: Text(
                                'Mood: ${dreamData['mood']} • Quality: ${dreamData['quality']}/5',
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textMediumGray,
                                    ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: AppTheme.textMediumGray,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.dreamDetailView,
                                  arguments: dreamData['id'],
                                );
                              },
                            ),
                          );
                        },
                        childCount:
                            _getMockDreamsForDate(_selectedDay).isEmpty
                                ? 1
                                : _getMockDreamsForDate(_selectedDay).length,
                      ),
                    ),
                  ],

                    // Bottom padding
                    SliverToBoxAdapter(child: SizedBox(height: 10.h)),
                  ],
                ),
              ),
    );
  }

  // Simplified helper methods
  String _getMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<Map<String, dynamic>> _getMockDreamsForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _mockDreamData[normalizedDate] ?? [];
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
  }

  void _navigateToNext() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  Future<void> _loadDreams() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  Future<void> _refreshData() async {
    await _loadDreams();
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../calendar_view/calendar_view.dart';
import '../dream_insights_dashboard/dream_insights_dashboard.dart';
import '../dream_journal_home/dream_journal_home.dart';
import '../settings_and_profile/settings_and_profile.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  late PageController _pageController;

  final List<Widget> _pages = [
    const DreamJournalHome(),
    const DreamInsightsDashboard(),
    const CalendarView(),
    const SettingsAndProfile(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: 'Insights',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'Calendar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryDarkPurple,
          border: Border(
            top: BorderSide(
              color: AppTheme.borderPurple.withAlpha(128),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 8.h,
            child: Row(
              children:
                  _navItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = _currentIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabSelected(index),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSelected
                                    ? (item.activeIcon as Icon).icon
                                    : (item.icon as Icon).icon,
                                color:
                                    isSelected
                                        ? AppTheme.textWhite
                                        : AppTheme.textMediumGray,
                                size: 5.w,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                item.label!,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? AppTheme.textWhite
                                          : AppTheme.textMediumGray,
                                  fontSize: 10.sp,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.dreamEntryCreation);
                },
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: AppTheme.textWhite,
                elevation: 6,
                child: Icon(Icons.add, size: 6.w, color: AppTheme.textWhite),
              )
              : null,
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_theme.dart';
import '../calendar_view/calendar_view.dart';
import '../dream_insights_dashboard/dream_insights_dashboard.dart';
import '../dream_journal_home/dream_journal_home.dart';
import '../public_dreams_feed/public_dreams_feed.dart';
import '../settings_and_profile/settings_and_profile.dart';

// REMOVED: Public Dreams Feed - hidden for MVP
//

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String? _sessionId;

  // MVP Flow: Home → Insights → Calendar → Profile
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
    _initializeAnalytics();
  }

  Future<void> _initializeAnalytics() async {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await AnalyticsService.trackAppOpened(sessionId: _sessionId);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Track screen navigation
    final screenNames = [
      'dream_journal_home',
      'dream_insights_dashboard',
      'calendar_view',
      'settings_and_profile',
    ];

    if (index < screenNames.length) {
      AnalyticsService.trackScreenView(
        screenName: screenNames[index],
        sessionId: _sessionId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: PageController(initialPage: _selectedIndex),
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryBurgundy,
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
            height: 65,
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == index;

                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onItemTapped(index),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: AppTheme.accentRedPurple.withAlpha(51),
                      highlightColor: AppTheme.accentRedPurple.withAlpha(26),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected
                                  ? (item.activeIcon as Icon).icon
                                  : (item.icon as Icon).icon,
                              color: isSelected
                                  ? AppTheme.textWhite
                                  : AppTheme.textMediumGray,
                              size: 26,
                            ),
                            SizedBox(height: 4),
                            Text(
                              item.label!,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.textWhite
                                    : AppTheme.textMediumGray,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.dreamEntryCreation);
                },
                backgroundColor: AppTheme.accentRedPurple,
                foregroundColor: AppTheme.textWhite,
                elevation: 6,
                heroTag: 'add_dream_fab',
                child: Icon(Icons.add, size: 28, color: AppTheme.textWhite),
              ),
            )
          : null,
    );
  }
}

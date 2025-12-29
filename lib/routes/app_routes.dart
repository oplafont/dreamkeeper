import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../presentation/advanced_analytics_dashboard/advanced_analytics_dashboard.dart';
import '../presentation/auth/auth_screen.dart';
import '../presentation/calendar_view/calendar_view.dart';
import '../presentation/dream_detail_view/dream_detail_view.dart';
import '../presentation/dream_entry_creation/dream_entry_creation.dart';
import '../presentation/dream_insights_dashboard/dream_insights_dashboard.dart';
import '../presentation/dream_journal_home/dream_journal_home.dart';
import '../presentation/export_sharing_center/export_sharing_center.dart';
import '../presentation/main_navigation/main_navigation.dart';
import '../presentation/public_dreams_feed/public_dreams_feed.dart';
import '../presentation/settings_and_profile/settings_and_profile.dart';
import '../presentation/sleep_quality_tracking/sleep_quality_tracking.dart';
import '../presentation/smart_notifications_management/smart_notifications_management.dart';
import '../presentation/subscription_checkout/subscription_checkout.dart';
import '../presentation/subscription_management/subscription_management.dart';
import '../presentation/therapeutic_insights_hub/therapeutic_insights_hub.dart';
import '../services/auth_service.dart';

// REMOVED FOR MVP: Advanced Analytics Dashboard
//
// REMOVED FOR MVP: Public Dreams Feed
//

class AppRoutes {
  static const String authWrapper = '/';
  static const String mainNavigation = '/main-navigation';
  static const String dreamJournalHome = '/dream-journal-home';
  static const String dreamEntryCreation = '/dream-entry-creation';
  static const String dreamDetailView = '/dream-detail-view';
  static const String calendarView = '/calendar-view';
  static const String dreamInsightsDashboard = '/dream-insights-dashboard';
  // REMOVED FOR MVP: static const String publicDreamsFeed = '/public-dreams-feed';
  // REMOVED FOR MVP: static const String advancedAnalyticsDashboard = '/advanced-analytics-dashboard';
  static const String settingsAndProfile = '/settings-and-profile';
  static const String sleepQualityTracking = '/sleep-quality-tracking';
  static const String smartNotificationsManagement =
      '/smart-notifications-management';
  static const String therapeuticInsightsHub = '/therapeutic-insights-hub';
  static const String exportSharingCenter = '/export-sharing-center';
  static const String subscriptionCheckout = '/subscription-checkout';
  static const String subscriptionManagement = '/subscription-management';

  // Changed initial route to AuthWrapper for mandatory authentication
  static const String initial = AppRoutes.authWrapper;

  static Map<String, WidgetBuilder> get routes => {
    authWrapper: (context) => const AuthWrapper(),
    mainNavigation: (context) => const MainNavigation(),
    dreamJournalHome: (context) => const DreamJournalHome(),
    dreamEntryCreation: (context) => const DreamEntryCreation(),
    dreamDetailView: (context) => const DreamDetailView(),
    calendarView: (context) => const CalendarView(),
    dreamInsightsDashboard: (context) => const DreamInsightsDashboard(),
    // REMOVED FOR MVP: publicDreamsFeed and advancedAnalyticsDashboard
    settingsAndProfile: (context) => const SettingsAndProfile(),
    sleepQualityTracking: (context) => const SleepQualityTracking(),
    smartNotificationsManagement: (context) =>
        const SmartNotificationsManagement(),
    therapeuticInsightsHub: (context) => const TherapeuticInsightsHub(),
    exportSharingCenter: (context) => const ExportSharingCenter(),
  };
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<AuthState>(
      stream: authService.authStateStream,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.purple),
            ),
          );
        }

        // Check if user is authenticated from AuthState
        final isAuthenticated = snapshot.data?.session != null;

        if (isAuthenticated) {
          return const MainNavigation();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

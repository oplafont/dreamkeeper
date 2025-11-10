import 'package:flutter/material.dart';
import '../presentation/main_navigation/main_navigation.dart';
import '../presentation/auth/auth_screen.dart';
import '../presentation/subscription_checkout/subscription_checkout.dart';
import '../presentation/subscription_management/subscription_management.dart';
import '../services/auth_service.dart';

class AppRoutes {
  static const String mainNavigation = '/main_navigation';
  static const String smartNotificationsManagement =
      '/smart_notifications_management';
  static const String dreamJournalHome = '/dream_journal_home';
  static const String dreamInsightsDashboard = '/dream_insights_dashboard';
  static const String dreamDetailView = '/dream_detail_view';
  static const String calendarView = '/calendar_view';
  static const String dreamEntryCreation = '/dream_entry_creation';
  static const String authScreen = '/auth_screen';
  static const String sleepQualityTracking = '/sleep_quality_tracking';
  static const String advancedAnalyticsDashboard =
      '/advanced_analytics_dashboard';
  static const String exportSharingCenter = '/export_sharing_center';
  static const String therapeuticInsightsHub = '/therapeutic_insights_hub';
  static const String settingsAndProfile = '/settings_and_profile';
  static const String subscriptionCheckout = '/subscription_checkout';
  static const String subscriptionManagement = '/subscription_management';

  static const String initial = AppRoutes.authScreen;

  static Map<String, WidgetBuilder> routes = {
    authScreen: (context) => const AuthScreen(),
    subscriptionCheckout: (context) => SubscriptionCheckoutScreen(),
    subscriptionManagement: (context) => SubscriptionManagementScreen(),
  };
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
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

        // Check if user is authenticated
        final isAuthenticated = authService.isAuthenticated;

        if (isAuthenticated) {
          return const MainNavigation();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}

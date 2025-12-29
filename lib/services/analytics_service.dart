import 'package:flutter/foundation.dart';
import './supabase_service.dart';

class AnalyticsService {
  static final SupabaseService _supabase = SupabaseService.instance;

  // Track analytics event
  static Future<void> trackEvent({
    required String eventType,
    Map<String, dynamic>? eventData,
    String? screenName,
    String? sessionId,
  }) async {
    try {
      final userId = _supabase.client.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.client.rpc(
        'track_analytics_event',
        params: {
          'p_user_id': userId,
          'p_event_type': eventType,
          'p_event_data': eventData ?? {},
          'p_screen_name': screenName,
          'p_session_id': sessionId,
        },
      );
    } catch (e) {
      debugPrint('Analytics tracking error: $e');
    }
  }

  // Track dream submission
  static Future<void> trackDreamSubmission({
    required String dreamType,
    required int wordCount,
  }) async {
    await trackEvent(
      eventType: 'dream_created',
      eventData: {
        'dream_type': dreamType,
        'word_count': wordCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
      screenName: 'dream_entry_creation',
    );
  }

  // Track feed interaction
  static Future<void> trackFeedView({int? scrollDepth}) async {
    await trackEvent(
      eventType: 'feed_view',
      eventData: {
        'scroll_depth': scrollDepth ?? 0,
        'timestamp': DateTime.now().toIso8601String(),
      },
      screenName: 'public_dreams_feed',
    );
  }

  // Track feed dream viewed
  static Future<void> trackFeedDreamViewed({
    required String dreamId,
    required String dreamTitle,
  }) async {
    await trackEvent(
      eventType: 'feed_dream_viewed',
      eventData: {
        'dream_id': dreamId,
        'dream_title': dreamTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
      screenName: 'public_dreams_feed',
    );
  }

  // Track symbol filter
  static Future<void> trackSymbolFilter({
    required String symbol,
    required int resultsCount,
  }) async {
    await trackEvent(
      eventType: 'feed_symbol_filtered',
      eventData: {
        'symbol': symbol,
        'results_count': resultsCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
      screenName: 'public_dreams_feed',
    );
  }

  // Track search
  static Future<void> trackSearch({
    required String query,
    required int resultsCount,
  }) async {
    await trackEvent(
      eventType: 'search_performed',
      eventData: {
        'query': query,
        'results_count': resultsCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Track insight generation
  static Future<void> trackInsightGeneration({
    required String insightType,
    required double confidence,
  }) async {
    await trackEvent(
      eventType: 'insight_generated',
      eventData: {
        'insight_type': insightType,
        'confidence': confidence,
        'timestamp': DateTime.now().toIso8601String(),
      },
      screenName: 'dream_insights_dashboard',
    );
  }

  // Track feature usage
  static Future<void> trackFeatureUsage({
    required String featureName,
    String? screenName,
  }) async {
    await trackEvent(
      eventType: 'screen_viewed',
      eventData: {
        'feature_name': featureName,
        'timestamp': DateTime.now().toIso8601String(),
      },
      screenName: screenName,
    );
  }

  // Get user analytics overview
  static Future<Map<String, dynamic>?> getUserAnalyticsOverview() async {
    try {
      final userId = _supabase.client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase.client.rpc(
        'get_user_analytics_overview',
        params: {'target_user_id': userId},
      );

      if (response != null && response.isNotEmpty) {
        return response.first as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching analytics overview: $e');
      return null;
    }
  }

  // Get daily active users
  static Future<int> getDailyActiveUsers({DateTime? targetDate}) async {
    try {
      final date = targetDate ?? DateTime.now();
      final response = await _supabase.client.rpc(
        'get_daily_active_users',
        params: {'target_date': date.toIso8601String().split('T')[0]},
      );

      return response as int? ?? 0;
    } catch (e) {
      debugPrint('Error fetching daily active users: $e');
      return 0;
    }
  }

  // Get user engagement summary
  static Future<Map<String, dynamic>?> getUserEngagementSummary() async {
    try {
      final userId = _supabase.client.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase.client
          .from('user_engagement_summary')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching engagement summary: $e');
      return null;
    }
  }

  // Get analytics aggregates
  static Future<List<Map<String, dynamic>>> getAnalyticsAggregates({
    required String metricType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.client
          .from('analytics_aggregates')
          .select()
          .eq('metric_type', metricType);

      if (startDate != null) {
        query =
            query.gte('metric_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query =
            query.lte('metric_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('metric_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching analytics aggregates: $e');
      return [];
    }
  }

  // Track app opened
  static Future<void> trackAppOpened({String? sessionId}) async {
    await trackEvent(
      eventType: 'app_opened',
      screenName: 'main_navigation',
      sessionId: sessionId,
    );
  }

  // Track screen view
  static Future<void> trackScreenView({
    required String screenName,
    String? sessionId,
  }) async {
    await trackEvent(
      eventType: 'screen_viewed',
      screenName: screenName,
      sessionId: sessionId,
    );
  }
}
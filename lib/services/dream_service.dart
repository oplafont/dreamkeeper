import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/openai_client.dart';
import '../services/openai_service.dart';
import '../services/realtime_service.dart';
import '../services/supabase_service.dart';

class DreamService {
  final client = SupabaseService.instance.client;
  late final OpenAIClient _aiClient;
  final RealtimeService _realtimeService = RealtimeService();

  DreamService() {
    _aiClient = OpenAIClient(OpenAIService().dio);
  }

  // Dream CRUD Operations

  /// Create a new dream entry with optional AI analysis
  /// NOW USES SUPABASE EDGE FUNCTION FOR SECURE SERVER-SIDE AI PROCESSING
  Future<Map<String, dynamic>> createDream({
    required String content,
    String? title,
    String? mood,
    List<String>? tags,
    String? dreamType,
    String? sleepQuality,
    bool? isLucid,
    bool? isNightmare,
    bool? isRecurring,
    int? clarityScore,
    bool performAIAnalysis = true,
  }) async {
    try {
      Map<String, dynamic> dreamData = {
        'content': content,
        'user_id': client.auth.currentUser?.id,
        'dream_date': DateTime.now().toIso8601String().split('T')[0],
      };

      // Add optional fields
      if (title != null) dreamData['title'] = title;
      if (mood != null) dreamData['mood'] = mood;
      if (tags != null) dreamData['tags'] = tags;
      if (dreamType != null) dreamData['dream_type'] = dreamType;
      if (sleepQuality != null) dreamData['sleep_quality'] = sleepQuality;
      if (isLucid != null) dreamData['is_lucid'] = isLucid;
      if (isNightmare != null) dreamData['is_nightmare'] = isNightmare;
      if (isRecurring != null) dreamData['is_recurring'] = isRecurring;
      if (clarityScore != null) dreamData['clarity_score'] = clarityScore;

      // Perform AI analysis if requested - NOW VIA EDGE FUNCTION
      if (performAIAnalysis) {
        try {
          // Edge Function handles JWT verification and OpenAI call server-side
          final analysis = await _aiClient.analyzeDreamContent(
            dreamContent: content,
            mood: mood,
            userTags: tags,
          );

          // Store AI analysis results in database
          dreamData['ai_analysis'] = analysis;
          dreamData['ai_tags'] = analysis['ai_tags'];
          dreamData['ai_symbols'] = analysis['ai_symbols'];
          dreamData['ai_emotions'] = analysis['ai_emotions'];
          dreamData['ai_themes'] = analysis['ai_themes'];

          // Update clarity score if AI provided one
          if (analysis['clarity_assessment'] != null && clarityScore == null) {
            dreamData['clarity_score'] = analysis['clarity_assessment'];
          }
        } catch (e) {
          print('AI analysis via Edge Function failed: $e');
          // Continue without AI analysis - dream still gets saved
        }
      }

      final response = await client
          .from('dreams')
          .insert(dreamData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create dream: $error');
    }
  }

  /// Get all dreams for current user with optional filtering
  Future<List<Map<String, dynamic>>> getUserDreams({
    int limit = 50,
    String? dreamType,
    String? mood,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = client
          .from('dreams')
          .select()
          .eq('user_id', client.auth.currentUser!.id);

      if (dreamType != null) {
        query = query.eq('dream_type', dreamType);
      }
      if (mood != null) {
        query = query.eq('mood', mood);
      }
      if (startDate != null) {
        query = query.gte(
          'dream_date',
          startDate.toIso8601String().split('T')[0],
        );
      }
      if (endDate != null) {
        query = query.lte(
          'dream_date',
          endDate.toIso8601String().split('T')[0],
        );
      }

      final response = await query
          .order('dream_date', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch dreams: $error');
    }
  }

  /// Get a single dream by ID
  Future<Map<String, dynamic>?> getDreamById(String dreamId) async {
    try {
      final response = await client
          .from('dreams')
          .select()
          .eq('id', dreamId)
          .eq('user_id', client.auth.currentUser!.id)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to fetch dream: $error');
    }
  }

  /// Update a dream entry
  Future<Map<String, dynamic>> updateDream(
    String dreamId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await client
          .from('dreams')
          .update(updates)
          .eq('id', dreamId)
          .eq('user_id', client.auth.currentUser!.id)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update dream: $error');
    }
  }

  /// Delete a dream entry
  Future<void> deleteDream(String dreamId) async {
    try {
      await client
          .from('dreams')
          .delete()
          .eq('id', dreamId)
          .eq('user_id', client.auth.currentUser!.id);
    } catch (error) {
      throw Exception('Failed to delete dream: $error');
    }
  }

  // Voice Recording Operations

  /// Transcribe audio recording and create dream entry
  Future<Map<String, dynamic>> createDreamFromAudio({
    required File audioFile,
    String? title,
    String? mood,
    List<String>? tags,
  }) async {
    try {
      // First, transcribe the audio
      final transcription = await _aiClient.transcribeAudio(
        audioFile: audioFile,
        prompt:
            'This is a dream journal recording. Please transcribe the dream description accurately.',
      );

      // Upload audio file to storage
      final userId = client.auth.currentUser!.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final audioPath = '$userId/recordings/dream_$timestamp.m4a';

      await client.storage
          .from('dream-recordings')
          .upload(audioPath, audioFile);

      // Create dream entry with transcription
      final dreamData = await createDream(
        content: transcription.text,
        title: title ?? 'Voice Dream Entry',
        mood: mood,
        tags: tags,
      );

      // Update dream with audio path
      final updatedDream = await updateDream(dreamData['id'], {
        'audio_recording_path': audioPath,
      });

      return updatedDream;
    } catch (error) {
      throw Exception('Failed to create dream from audio: $error');
    }
  }

  // Dream Analytics and Insights

  /// Get dream statistics for current user
  Future<Map<String, dynamic>> getDreamStatistics() async {
    try {
      final userId = client.auth.currentUser!.id;
      final response = await client.rpc(
        'get_dream_statistics',
        params: {'user_uuid': userId},
      );
      return response;
    } catch (error) {
      throw Exception('Failed to fetch dream statistics: $error');
    }
  }

  /// Generate AI insights from recent dreams
  Future<String> generateDreamInsights({
    required String insightType, // 'patterns', 'emotions', 'symbols', 'themes'
    int dreamCount = 10,
  }) async {
    try {
      // Get recent dreams
      final recentDreams = await getUserDreams(limit: dreamCount);

      if (recentDreams.isEmpty) {
        return 'No recent dreams available for analysis. Start recording your dreams to get personalized insights!';
      }

      // Generate insights using AI
      final insights = await _aiClient.generateDreamInsights(
        recentDreams: recentDreams,
        insightType: insightType,
      );

      return insights;
    } catch (error) {
      throw Exception('Failed to generate insights: $error');
    }
  }

  /// Save generated insight to database
  Future<Map<String, dynamic>> saveInsight({
    required String insightType,
    required String title,
    required String content,
    List<String>? relatedDreamIds,
    double? confidenceScore,
  }) async {
    try {
      final insightData = {
        'user_id': client.auth.currentUser!.id,
        'insight_type': insightType,
        'insight_title': title,
        'insight_content': content,
        'confidence_score': confidenceScore ?? 0.8,
      };

      if (relatedDreamIds != null) {
        insightData['related_dreams'] = relatedDreamIds;
      }

      final response = await client
          .from('dream_insights')
          .insert(insightData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to save insight: $error');
    }
  }

  /// Get all insights for current user
  Future<List<Map<String, dynamic>>> getUserInsights({int limit = 20}) async {
    try {
      final response = await client
          .from('dream_insights')
          .select()
          .eq('user_id', client.auth.currentUser!.id)
          .order('date_generated', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch insights: $error');
    }
  }

  // Search and Filtering

  /// Search dreams by content, tags, or AI analysis
  Future<List<Map<String, dynamic>>> searchDreams({
    required String searchTerm,
    List<String>? tagFilters,
    List<String>? moodFilters,
  }) async {
    try {
      var query = client
          .from('dreams')
          .select()
          .eq('user_id', client.auth.currentUser!.id);

      // Apply filters
      if (tagFilters != null && tagFilters.isNotEmpty) {
        query = query.overlaps('tags', tagFilters);
      }
      if (moodFilters != null && moodFilters.isNotEmpty) {
        query = query.inFilter('mood', moodFilters);
      }

      // Text search in content and title
      if (searchTerm.isNotEmpty) {
        query = query.or(
          'content.ilike.%$searchTerm%,title.ilike.%$searchTerm%',
        );
      }

      final response = await query
          .order('dream_date', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search dreams: $error');
    }
  }

  /// Get dreams by date range for calendar view
  Future<List<Map<String, dynamic>>> getDreamsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await client
          .from('dreams')
          .select('id, title, dream_date, mood, is_lucid, clarity_score')
          .eq('user_id', client.auth.currentUser!.id)
          .gte('dream_date', startDate.toIso8601String().split('T')[0])
          .lte('dream_date', endDate.toIso8601String().split('T')[0])
          .order('dream_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch dreams by date range: $error');
    }
  }

  // Paginated Public Dreams Feed Operations

  /// Get public dreams with pagination support
  Future<Map<String, dynamic>> getPublicDreamsPaginated({
    required int page,
    required int pageSize,
    String? category,
    String? sortOption,
    String? searchText,
    Map<String, dynamic>? advancedFilters,
  }) async {
    try {
      final offset = page * pageSize;
      var query = client
          .from('dreams')
          .select(
            'id, title, content, mood, tags, ai_symbols, ai_emotions, created_at, user_id, is_lucid, is_nightmare, is_recurring, dream_type',
          );

      // Apply category filters
      if (category != null && category != 'all') {
        switch (category) {
          case 'trending':
            // Trending based on recent views (simulated with created_at for now)
            query = query.gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(days: 7))
                  .toIso8601String(),
            );
            break;
          case 'lucid':
            query = query.eq('is_lucid', true);
            break;
          case 'nightmares':
            query = query.eq('is_nightmare', true);
            break;
          case 'recurring':
            query = query.eq('is_recurring', true);
            break;
          case 'prophetic':
            query = query.eq('dream_type', 'prophetic');
            break;
        }
      }

      // Apply search text filter
      if (searchText != null && searchText.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchText%,content.ilike.%$searchText%',
        );
      }

      // Apply advanced filters
      if (advancedFilters != null) {
        if (advancedFilters['emotion'] != null &&
            advancedFilters['emotion'] != 'all') {
          query = query.eq('mood', advancedFilters['emotion']);
        }

        if (advancedFilters['symbols'] != null &&
            (advancedFilters['symbols'] as List).isNotEmpty) {
          query = query.overlaps(
            'ai_symbols',
            advancedFilters['symbols'] as List,
          );
        }
      }

      // Apply sorting
      switch (sortOption ?? 'trending') {
        case 'recent':
          break;
        case 'trending':
          break;
        default:
      }

      // Get total count for pagination
      final countResponse = await query.count();
      final totalCount = countResponse.count;

      // Apply sorting and pagination
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + pageSize - 1);

      return {
        'dreams': List<Map<String, dynamic>>.from(response),
        'totalCount': totalCount,
        'hasMore': (offset + pageSize) < totalCount,
        'currentPage': page,
      };
    } catch (error) {
      throw Exception('Failed to fetch public dreams: $error');
    }
  }

  /// Get AI-powered dream recommendations
  Future<List<Map<String, dynamic>>> getAIRecommendations({
    required Map<String, dynamic> userPreferences,
    int limit = 5,
  }) async {
    try {
      // Build query based on user preferences
      var query = client
          .from('dreams')
          .select(
            'id, title, content, mood, tags, ai_symbols, ai_emotions, ai_themes, created_at',
          );

      // Filter by preferred themes
      final themes = userPreferences['themes'] as String?;
      if (themes != null) {
        final themeList = themes.split(',').map((t) => t.trim()).toList();
        if (themeList.isNotEmpty) {
          query = query.overlaps('ai_themes', themeList);
        }
      }

      // Filter by preferred emotions
      final emotions = userPreferences['emotions'] as List?;
      if (emotions != null && emotions.isNotEmpty) {
        query = query.inFilter('mood', emotions);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch AI recommendations: $error');
    }
  }

  /// Get trending dreams (most recent with high engagement)
  Future<List<Map<String, dynamic>>> getTrendingDreams({int limit = 10}) async {
    try {
      final response = await client
          .from('dreams')
          .select(
            'id, title, content, mood, tags, ai_symbols, created_at, user_id',
          )
          .gte(
            'created_at',
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          )
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch trending dreams: $error');
    }
  }

  // Real-time Subscription Methods

  /// Subscribe to real-time dream submissions
  /// Automatically syncs new dreams across all users without manual refresh
  RealtimeChannel subscribeToNewDreams({
    required Function(Map<String, dynamic>) onNewDream,
    Function(Map<String, dynamic>)? onDreamUpdated,
    Function(Map<String, dynamic>)? onDreamDeleted,
  }) {
    return _realtimeService.subscribeToDreams(
      onInsert: onNewDream,
      onUpdate: onDreamUpdated,
      onDelete: onDreamDeleted,
      channelName: 'public-dreams-feed',
    );
  }

  /// Subscribe to real-time engagement metric updates
  /// Tracks changes to user engagement summaries
  RealtimeChannel subscribeToEngagementMetrics({
    required Function(Map<String, dynamic>) onEngagementUpdate,
  }) {
    return _realtimeService.subscribeToEngagement(
      onUpdate: onEngagementUpdate,
      channelName: 'engagement-metrics',
    );
  }

  /// Subscribe to category-specific dream updates
  RealtimeChannel subscribeToCategoryDreams({
    required String category,
    required Function(Map<String, dynamic>) onNewDream,
    Function(Map<String, dynamic>)? onDreamUpdated,
  }) {
    return _realtimeService.subscribeToDreamsByCategory(
      category: category,
      onInsert: onNewDream,
      onUpdate: onDreamUpdated,
      channelName: 'dreams-category-$category',
    );
  }

  /// Subscribe to a specific dream's updates
  RealtimeChannel subscribeToSpecificDream({
    required String dreamId,
    required Function(Map<String, dynamic>) onDreamUpdated,
    Function(Map<String, dynamic>)? onDreamDeleted,
  }) {
    return _realtimeService.subscribeToDreamById(
      dreamId: dreamId,
      onUpdate: onDreamUpdated,
      onDelete: onDreamDeleted,
      channelName: 'dream-detail-$dreamId',
    );
  }

  /// Unsubscribe from real-time updates
  Future<void> unsubscribeFromRealtimeUpdates(String channelName) async {
    await _realtimeService.unsubscribe(channelName);
  }

  /// Unsubscribe from all real-time channels
  Future<void> unsubscribeFromAllRealtimeUpdates() async {
    await _realtimeService.unsubscribeAll();
  }

  /// Check if subscribed to a specific channel
  bool isSubscribedToChannel(String channelName) {
    return _realtimeService.isChannelActive(channelName);
  }

  /// Get list of active subscription channels
  List<String> getActiveSubscriptions() {
    return _realtimeService.getActiveChannels();
  }
}

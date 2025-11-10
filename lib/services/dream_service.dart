import 'dart:io';

import '../services/openai_client.dart';
import '../services/openai_service.dart';
import '../services/supabase_service.dart';

class DreamService {
  final client = SupabaseService.instance.client;
  late final OpenAIClient _aiClient;

  DreamService() {
    _aiClient = OpenAIClient(OpenAIService().dio);
  }

  // Dream CRUD Operations

  /// Create a new dream entry with optional AI analysis
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

      // Perform AI analysis if requested
      if (performAIAnalysis) {
        try {
          final analysis = await _aiClient.analyzeDreamContent(
            dreamContent: content,
            mood: mood,
            userTags: tags,
          );

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
          print('AI analysis failed: $e');
          // Continue without AI analysis
        }
      }

      final response =
          await client.from('dreams').insert(dreamData).select().single();
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
        query =
            query.gte('dream_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query =
            query.lte('dream_date', endDate.toIso8601String().split('T')[0]);
      }

      final response =
          await query.order('dream_date', ascending: false).limit(limit);
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
      String dreamId, Map<String, dynamic> updates) async {
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
      final response = await client
          .rpc('get_dream_statistics', params: {'user_uuid': userId});
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
        query =
            query.or('content.ilike.%$searchTerm%,title.ilike.%$searchTerm%');
      }

      final response =
          await query.order('dream_date', ascending: false).limit(50);
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
}

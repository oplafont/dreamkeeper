import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  late final Dio _dio;
  // REMOVED: API key is no longer stored client-side
  // NOW: API key is securely stored in Supabase secrets and used by Edge Function
  bool _isConfigured = false;

  // Factory constructor to return the singleton instance
  factory OpenAIService() {
    return _instance;
  }

  // Private constructor for singleton pattern
  OpenAIService._internal() {
    _initializeService();
  }

  void _initializeService() {
    // Configure Dio for non-dream OpenAI features (if any remain client-side)
    // Dream analysis now uses Supabase Edge Function
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openai.com/v1',
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _isConfigured = true;
  }

  Dio get dio => _dio;

  // REMOVED: Direct OpenAI methods for dream analysis
  // Dream analysis is now handled by Supabase Edge Function 'analyze_dream'

  // Keep other OpenAI methods if needed for different features
  // But for dream analysis, all calls go through Edge Function

  Future<List<String>> generateReflectionQuestions(String dreamThemes) async {
    // This method can stay if needed for other features
    // But ideally would also move to Edge Function for security
    if (!_isConfigured) {
      throw Exception('OpenAI service not configured properly');
    }

    // ... existing code for reflection questions if still needed client-side ...
    // For production: Consider moving this to Edge Function too

    // Returning default for now as this should ideally be server-side too
    return [
      'How did the emotions in your dreams relate to your current life experiences?',
      'What patterns do you notice in your recent dreams that might reflect your inner thoughts?',
      'How can you apply the insights from your dreams to support your emotional well-being?',
    ];
  }

  Future<List<Map<String, dynamic>>> generateTherapeuticActions(
    Map<String, dynamic> dreamPatterns,
  ) async {
    // This method can stay if needed for other features
    // But ideally would also move to Edge Function for security
    return _getDefaultTherapeuticActions();
  }

  List<Map<String, dynamic>> _getDefaultTherapeuticActions() {
    return [
      {
        'title': 'Mindful Dream Reflection',
        'description':
            'Spend time quietly reflecting on your dreams and the emotions they bring up.',
        'type': 'mindfulness',
        'duration': '10 minutes',
      },
      {
        'title': 'Emotional Check-in',
        'description':
            'Practice identifying and naming your current emotional state.',
        'type': 'therapeutic',
        'duration': '5 minutes',
      },
      {
        'title': 'Gratitude Practice',
        'description':
            'Write down three things you\'re grateful for related to your dreams or sleep.',
        'type': 'behavioral',
        'duration': '10 minutes',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> generateDreamRecommendations(
    String userThemes,
  ) async {
    // Return default recommendations
    // For production: Move to Edge Function if OpenAI calls are needed
    return _getDefaultDreamRecommendations();
  }

  List<Map<String, dynamic>> _getDefaultDreamRecommendations() {
    return [
      {
        'id': 'rec1',
        'title': 'Dreams with Flying Themes',
        'description': 'Explore dreams about soaring and freedom',
        'matchScore': 95,
        'icon': Icons.flight_takeoff,
      },
      {
        'id': 'rec2',
        'title': 'Water and Ocean Dreams',
        'description': 'Discover dreams featuring water symbolism',
        'matchScore': 88,
        'icon': Icons.water,
      },
      {
        'id': 'rec3',
        'title': 'Emotional Journey Dreams',
        'description': 'Dreams exploring deep emotions',
        'matchScore': 82,
        'icon': Icons.favorite,
      },
    ];
  }
}

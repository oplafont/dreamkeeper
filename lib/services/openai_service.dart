import 'package:dio/dio.dart';


class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  late final Dio _dio;
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');
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
    // Load API key from environment variables
    if (apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY must be provided via --dart-define');
    }

    // Configure Dio with base URL and headers
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openai.com/v1',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );
    _isConfigured = true;
  }

  Dio get dio => _dio;

  Future<List<String>> generateReflectionQuestions(String dreamThemes) async {
    if (!_isConfigured) {
      throw Exception(
          'OpenAI service not configured. Please check your API key.');
    }

    try {
      final messages = [
        {
          'role': 'system',
          'content':
              'You are a therapeutic AI assistant specializing in dream analysis and emotional wellness. Generate thoughtful, open-ended reflection questions that help users explore their dreams and emotions in a therapeutic context. Focus on self-discovery, emotional processing, and personal growth.'
        },
        {
          'role': 'user',
          'content':
              'Based on these dream themes and patterns: "$dreamThemes", generate 3-5 therapeutic reflection questions that would help someone process their emotions and gain insights. Make the questions empathetic, non-judgmental, and focused on personal growth.'
        }
      ];

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': messages,
          'max_tokens': 300,
          'temperature': 0.7,
        },
      );

      final content =
          response.data['choices'][0]['message']['content'] as String;

      // Parse questions from the response
      final questions = content
          .split('\n')
          .where((line) =>
              line.trim().isNotEmpty &&
              (line.contains('?') || line.startsWith(RegExp(r'\d+'))))
          .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
          .where((question) => question.isNotEmpty)
          .toList();

      return questions.isNotEmpty
          ? questions
          : [
              'How did the emotions in your dreams relate to your current life experiences?',
              'What patterns do you notice in your recent dreams that might reflect your inner thoughts?',
              'How can you apply the insights from your dreams to support your emotional well-being?'
            ];
    } catch (e) {
      throw Exception(
          'Failed to generate reflection questions: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> generateTherapeuticActions(
      Map<String, dynamic> dreamPatterns) async {
    if (!_isConfigured) {
      throw Exception(
          'OpenAI service not configured. Please check your API key.');
    }

    try {
      final messages = [
        {
          'role': 'system',
          'content':
              'You are a therapeutic AI assistant that provides personalized wellness recommendations based on dream analysis. Generate specific, actionable therapeutic interventions that are evidence-based and suitable for self-directed wellness practices.'
        },
        {
          'role': 'user',
          'content':
              'Based on these dream patterns: ${dreamPatterns.toString()}, suggest 3-4 therapeutic actions or interventions. For each action, provide: title, description, type (mindfulness/behavioral/therapeutic), and estimated duration. Focus on practical, safe activities that promote emotional wellness and self-awareness.'
        }
      ];

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o-mini',
          'messages': messages,
          'max_tokens': 400,
          'temperature': 0.6,
        },
      );

      final content =
          response.data['choices'][0]['message']['content'] as String;

      // Parse therapeutic actions from response
      final actions = <Map<String, dynamic>>[];
      final lines =
          content.split('\n').where((line) => line.trim().isNotEmpty).toList();

      for (int i = 0; i < lines.length; i += 4) {
        if (i + 3 < lines.length) {
          final title =
              lines[i].replaceAll(RegExp(r'^\d+\.\s*\*?\*?'), '').trim();
          final description = lines[i + 1].trim();
          final type = _extractActionType(lines[i + 2]);
          final duration = _extractDuration(lines[i + 3]);

          actions.add({
            'title': title,
            'description': description,
            'type': type,
            'duration': duration,
          });
        }
      }

      return actions.isNotEmpty ? actions : _getDefaultTherapeuticActions();
    } catch (e) {
      return _getDefaultTherapeuticActions();
    }
  }

  String _extractActionType(String line) {
    final types = ['mindfulness', 'behavioral', 'therapeutic'];
    for (final type in types) {
      if (line.toLowerCase().contains(type)) {
        return type;
      }
    }
    return 'therapeutic';
  }

  String _extractDuration(String line) {
    final durationMatch = RegExp(r'(\d+)\s*(minutes?|mins?|hours?|hrs?)')
        .firstMatch(line.toLowerCase());
    if (durationMatch != null) {
      return '${durationMatch.group(1)} ${durationMatch.group(2)}';
    }
    return '15 minutes';
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
}

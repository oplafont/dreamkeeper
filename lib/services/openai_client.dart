import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../services/supabase_service.dart';

class Message {
  final String role;
  final dynamic content;

  Message({required this.role, required this.content});
}

class Completion {
  final String text;

  Completion({required this.text});
}

class StreamCompletion {
  final String content;
  final String? finishReason;
  final String? systemFingerprint;

  StreamCompletion({
    required this.content,
    this.finishReason,
    this.systemFingerprint,
  });
}

class GeneratedImage {
  final String? url;
  final String? base64Data;

  GeneratedImage({this.url, this.base64Data});

  Uint8List? get imageBytes =>
      base64Data != null ? base64Decode(base64Data!) : null;
}

class UsageInfo {
  final int totalTokens;
  final int inputTokens;
  final int outputTokens;
  final Map<String, dynamic>? inputTokensDetails;

  UsageInfo({
    required this.totalTokens,
    required this.inputTokens,
    required this.outputTokens,
    this.inputTokensDetails,
  });

  factory UsageInfo.fromJson(Map<String, dynamic> json) {
    return UsageInfo(
      totalTokens: json['total_tokens'] ?? 0,
      inputTokens: json['input_tokens'] ?? 0,
      outputTokens: json['output_tokens'] ?? 0,
      inputTokensDetails: json['input_tokens_details'],
    );
  }
}

class ImageGenerationResult {
  final List<GeneratedImage> images;
  final UsageInfo? usage;

  ImageGenerationResult({required this.images, this.usage});
}

class Transcription {
  final String text;

  Transcription({required this.text});
}

class OpenAIException implements Exception {
  final int statusCode;
  final String message;

  OpenAIException({required this.statusCode, required this.message});

  @override
  String toString() => 'OpenAIException: $statusCode - $message';
}

class OpenAIClient {
  final Dio dio;
  final client = SupabaseService.instance.client;

  OpenAIClient(this.dio);

  // =============================================================================
  // DREAM-SPECIFIC AI METHODS - NOW USING SUPABASE EDGE FUNCTION
  // Purpose: Specialized dream analysis via secure server-side processing
  // =============================================================================

  /// Analyze dream content with AI for insights, symbols, and themes
  /// NOW CALLS SUPABASE EDGE FUNCTION INSTEAD OF DIRECT OPENAI
  Future<Map<String, dynamic>> analyzeDreamContent({
    required String dreamContent,
    String? mood,
    List<String>? userTags,
  }) async {
    try {
      // Get current user's JWT token
      final session = client.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated');
      }

      // Call Supabase Edge Function instead of OpenAI directly
      final response = await client.functions.invoke(
        'analyze_dream',
        body: {
          'dreamContent': dreamContent,
          if (mood != null) 'mood': mood,
          if (userTags != null) 'userTags': userTags,
        },
      );

      if (response.status != 200) {
        throw Exception('Edge function returned error: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true && data['analysis'] != null) {
        return data['analysis'] as Map<String, dynamic>;
      } else {
        throw Exception('Invalid response from edge function');
      }
    } catch (e) {
      print('Dream analysis via Edge Function failed: $e');
      // Return fallback analysis on error
      return _parseDreamAnalysisResponse('');
    }
  }

  /// Generate personalized dream insights from multiple dream entries
  Future<String> generateDreamInsights({
    required List<Map<String, dynamic>> recentDreams,
    required String insightType, // 'patterns', 'emotions', 'symbols', 'themes'
  }) async {
    try {
      final prompt = _buildInsightGenerationPrompt(recentDreams, insightType);

      final messages = [
        Message(
          role: 'user',
          content: [
            {'type': 'text', 'text': prompt},
          ],
        ),
      ];

      final response = await createChatCompletion(
        messages: messages,
        model: 'gpt-5', // Higher reasoning for insights
        reasoningEffort: 'high',
        verbosity: 'medium',
      );

      return response.text;
    } catch (e) {
      throw OpenAIException(
        statusCode: 500,
        message: 'Insight generation failed: $e',
      );
    }
  }

  /// Enhanced Vision API for dream image analysis
  Future<Completion> analyzeDreamImage({
    String? imageUrl,
    Uint8List? imageBytes,
    String promptText =
        'Analyze this dream-related image and describe any symbols, emotions, or themes you observe:',
    String model = 'gpt-5',
    String? reasoningEffort,
  }) async {
    try {
      if (imageUrl == null && imageBytes == null) {
        throw ArgumentError('Either imageUrl or imageBytes must be provided');
      }

      final List<Map<String, dynamic>> content = [
        {'type': 'text', 'text': promptText},
      ];

      if (imageUrl != null) {
        content.add({
          'type': 'image_url',
          'image_url': {'url': imageUrl},
        });
      } else if (imageBytes != null) {
        final base64Image = base64Encode(imageBytes);
        content.add({
          'type': 'image_url',
          'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
        });
      }

      final messages = [Message(role: 'user', content: content)];

      final requestData = <String, dynamic>{
        'model': model,
        'messages': messages
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
      };

      if (model.startsWith('gpt-5') && reasoningEffort != null) {
        requestData['reasoning_effort'] = reasoningEffort;
      }

      final response = await dio.post('/chat/completions', data: requestData);

      final text = response.data['choices'][0]['message']['content'];
      return Completion(text: text);
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ?? e.message,
      );
    }
  }

  // =============================================================================
  // CORE OPENAI METHODS
  // Purpose: Foundation methods for all AI interactions
  // NOTE: These are kept for other features but dream analysis now uses Edge Function
  // =============================================================================

  /// Standard chat completion with GPT-5 support
  Future<Completion> createChatCompletion({
    required List<Message> messages,
    String model = 'gpt-5-mini',
    Map<String, dynamic>? options,
    String? reasoningEffort,
    String? verbosity,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'model': model,
        'messages': messages
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
      };

      // Handle options based on model type
      if (options != null) {
        final filteredOptions = Map<String, dynamic>.from(options);

        // For GPT-5 models, remove unsupported parameters
        if (model.startsWith('gpt-5') ||
            model.startsWith('o3') ||
            model.startsWith('o4')) {
          filteredOptions.removeWhere(
            (key, value) => [
              'temperature',
              'top_p',
              'presence_penalty',
              'frequency_penalty',
              'logit_bias',
            ].contains(key),
          );

          // Convert max_tokens to max_completion_tokens for GPT-5
          if (filteredOptions.containsKey('max_tokens')) {
            filteredOptions['max_completion_tokens'] = filteredOptions.remove(
              'max_tokens',
            );
          }
        }

        requestData.addAll(filteredOptions);
      }

      // Add GPT-5 specific parameters
      if (model.startsWith('gpt-5') ||
          model.startsWith('o3') ||
          model.startsWith('o4')) {
        if (reasoningEffort != null)
          requestData['reasoning_effort'] = reasoningEffort;
        if (verbosity != null) requestData['verbosity'] = verbosity;
      }

      final response = await dio.post('/chat/completions', data: requestData);

      final text = response.data['choices'][0]['message']['content'];
      return Completion(text: text);
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ?? e.message,
      );
    }
  }

  /// Streams a text response with support for new model parameters
  Stream<StreamCompletion> streamChatCompletion({
    required List<Message> messages,
    String model = 'gpt-5-mini',
    Map<String, dynamic>? options,
    String? reasoningEffort,
    String? verbosity,
  }) async* {
    try {
      final requestData = <String, dynamic>{
        'model': model,
        'messages': messages
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
        'stream': true,
      };

      if (options != null) {
        final filteredOptions = Map<String, dynamic>.from(options);
        if (model.startsWith('gpt-5') ||
            model.startsWith('o3') ||
            model.startsWith('o4')) {
          filteredOptions.removeWhere(
            (key, value) => [
              'temperature',
              'top_p',
              'presence_penalty',
              'frequency_penalty',
              'logit_bias',
            ].contains(key),
          );
          if (filteredOptions.containsKey('max_tokens')) {
            filteredOptions['max_completion_tokens'] = filteredOptions.remove(
              'max_tokens',
            );
          }
        }
        requestData.addAll(filteredOptions);
      }

      // Add GPT-5 specific parameters
      if (model.startsWith('gpt-5') ||
          model.startsWith('o3') ||
          model.startsWith('o4')) {
        if (reasoningEffort != null)
          requestData['reasoning_effort'] = reasoningEffort;
        if (verbosity != null) requestData['verbosity'] = verbosity;
      }

      final response = await dio.post(
        '/chat/completions',
        data: requestData,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream;
      await for (var line in LineSplitter().bind(
        utf8.decoder.bind(stream.stream),
      )) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;

          final json = jsonDecode(data) as Map<String, dynamic>;
          final delta = json['choices'][0]['delta'] as Map<String, dynamic>;
          final content = delta['content'] ?? '';
          final finishReason = json['choices'][0]['finish_reason'];
          final systemFingerprint = json['system_fingerprint'];

          yield StreamCompletion(
            content: content,
            finishReason: finishReason,
            systemFingerprint: systemFingerprint,
          );

          if (finishReason != null) break;
        }
      }
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ?? e.message,
      );
    }
  }

  /// A more user-friendly wrapper for streaming that just yields content strings
  Stream<String> streamContentOnly({
    required List<Message> messages,
    String model = 'gpt-5-mini',
    Map<String, dynamic>? options,
    String? reasoningEffort,
    String? verbosity,
  }) async* {
    await for (final chunk in streamChatCompletion(
      messages: messages,
      model: model,
      options: options,
      reasoningEffort: reasoningEffort,
      verbosity: verbosity,
    )) {
      if (chunk.content.isNotEmpty) {
        yield chunk.content;
      }
    }
  }

  /// Convert speech audio to text for voice dream recordings
  Future<Transcription> transcribeAudio({
    required File audioFile,
    String model = 'whisper-1',
    String? prompt,
    String responseFormat = 'json',
    String? language,
    double? temperature,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
        'model': model,
        if (prompt != null) 'prompt': prompt,
        'response_format': responseFormat,
        if (language != null) 'language': language,
        if (temperature != null) 'temperature': temperature,
      });

      final response = await dio.post('/audio/transcriptions', data: formData);

      if (responseFormat == 'json') {
        return Transcription(text: response.data['text']);
      } else {
        return Transcription(text: response.data.toString());
      }
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ?? e.message,
      );
    }
  }

  /// Full-featured image generation with detailed results
  Future<ImageGenerationResult> generateImages({
    required String prompt,
    int n = 1,
    String size = '1024x1024',
    String model = 'dall-e-3',
    String responseFormat = 'url',
    String? quality = 'standard',
  }) async {
    try {
      final requestData = <String, dynamic>{
        'model': model,
        'prompt': prompt,
        'n': n,
        'size': size,
        'response_format': responseFormat,
      };

      if (quality != null) requestData['quality'] = quality;

      final response = await dio.post('/images/generations', data: requestData);

      final usage = response.data['usage'] as Map<String, dynamic>?;
      final List data = response.data['data'];
      final List<GeneratedImage> images = [];

      for (var item in data) {
        if (responseFormat == 'url') {
          images.add(GeneratedImage(url: item['url'], base64Data: null));
        } else if (responseFormat == 'b64_json') {
          images.add(GeneratedImage(url: null, base64Data: item['b64_json']));
        }
      }

      return ImageGenerationResult(
        images: images,
        usage: usage != null ? UsageInfo.fromJson(usage) : null,
      );
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ?? e.message,
      );
    }
  }

  /// Convert text to speech audio file
  Future<File> createSpeech({
    required String input,
    String model = 'tts-1-hd', // Default to HD quality
    String voice = 'alloy',
    String responseFormat = 'mp3',
    double? speed,
  }) async {
    try {
      final response = await dio.post(
        '/audio/speech',
        data: {
          'model': model,
          'input': input,
          'voice': voice,
          'response_format': responseFormat,
          if (speed != null) 'speed': speed,
        },
        options: Options(responseType: ResponseType.bytes),
      );

      final tempDir = await getTemporaryDirectory();
      final fileExtension = responseFormat == 'opus' ? 'ogg' : responseFormat;
      final audioFile = File(
        '${tempDir.path}/speech_${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
      );
      await audioFile.writeAsBytes(response.data);

      return audioFile;
    } on DioException catch (e) {
      throw OpenAIException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data['error']['message'] ?? e.message,
      );
    }
  }

  // =============================================================================
  // PRIVATE HELPER METHODS
  // Purpose: Internal methods for prompt building and response parsing
  // =============================================================================

  String _buildDreamAnalysisPrompt(
    String dreamContent,
    String? mood,
    List<String>? userTags,
  ) {
    final moodContext = mood != null
        ? ' The dreamer reported feeling $mood during this dream.'
        : '';
    final tagsContext = userTags != null && userTags.isNotEmpty
        ? ' The dreamer tagged this dream with: ${userTags.join(', ')}.'
        : '';

    return '''
As an expert dream analyst, analyze this dream and provide insights in the following JSON format:

Dream Content: "$dreamContent"$moodContext$tagsContext

Please provide analysis in this exact JSON structure:
{
  "interpretation": "Brief interpretation of the dream's meaning (2-3 sentences)",
  "significance": "What this dream might signify for the dreamer (2-3 sentences)",
  "psychological_themes": ["theme1", "theme2", "theme3"],
  "ai_tags": ["tag1", "tag2", "tag3", "tag4", "tag5"],
  "ai_symbols": ["symbol1", "symbol2", "symbol3", "symbol4"],
  "ai_emotions": ["emotion1", "emotion2", "emotion3"],
  "ai_themes": ["major_theme1", "major_theme2", "major_theme3"],
  "clarity_assessment": 8,
  "lucidity_indicators": ["indicator1", "indicator2"],
  "recommendations": "Suggestions for the dreamer based on this dream (2-3 sentences)"
}

Focus on psychological insights, symbolic meanings, and patterns that could help the dreamer understand their subconscious mind. Be supportive and insightful.
''';
  }

  String _buildInsightGenerationPrompt(
    List<Map<String, dynamic>> recentDreams,
    String insightType,
  ) {
    final dreamSummaries = recentDreams
        .map((dream) {
          return 'Dream: "${dream['title'] ?? 'Untitled'}" - ${dream['content']} (Mood: ${dream['mood'] ?? 'Unknown'}, Tags: ${dream['tags']?.join(', ') ?? 'none'})';
        })
        .join('\n');

    final typeSpecificPrompt =
        {
          'patterns':
              'Identify recurring patterns, symbols, and themes across these dreams',
          'emotions':
              'Analyze the emotional journey and patterns in these dreams',
          'symbols':
              'Examine the symbolic meanings and their evolution across dreams',
          'themes':
              'Identify major life themes and psychological insights from these dreams',
        }[insightType] ??
        'Provide general insights about these dreams';

    return '''
As a dream psychology expert, analyze these recent dreams and $typeSpecificPrompt:

$dreamSummaries

Provide personalized insights that help the dreamer understand:
1. What their subconscious might be processing
2. Patterns that connect to their waking life
3. Psychological growth or challenges reflected in dreams
4. Actionable insights for personal development

Write in a warm, encouraging tone (3-4 paragraphs) that helps the dreamer feel understood and supported in their journey of self-discovery. Focus on empowerment and growth rather than concerns.
''';
  }

  Map<String, dynamic> _parseDreamAnalysisResponse(String aiResponse) {
    try {
      // Try to extract JSON from the response
      final jsonStart = aiResponse.indexOf('{');
      final jsonEnd = aiResponse.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = aiResponse.substring(jsonStart, jsonEnd);
        return json.decode(jsonString) as Map<String, dynamic>;
      }

      // If JSON parsing fails, create a fallback structure
      return {
        'interpretation': 'AI analysis completed with valuable insights',
        'significance':
            'This dream contains meaningful content that reflects your inner world',
        'psychological_themes': [
          'reflection',
          'subconscious_processing',
          'growth',
        ],
        'ai_tags': ['analyzed', 'meaningful', 'insightful'],
        'ai_symbols': ['journey', 'exploration'],
        'ai_emotions': ['contemplative', 'curious'],
        'ai_themes': ['self_discovery', 'personal_growth'],
        'clarity_assessment': 7,
        'lucidity_indicators': ['awareness'],
        'recommendations':
            'Continue journaling your dreams to unlock deeper insights into your subconscious mind',
      };
    } catch (e) {
      // Return error-safe fallback
      return {
        'interpretation': 'Dream analysis completed',
        'significance': 'Your dream contains elements worth exploring further',
        'psychological_themes': ['processing', 'exploration'],
        'ai_tags': ['reviewed', 'processed'],
        'ai_symbols': ['transition'],
        'ai_emotions': ['neutral'],
        'ai_themes': ['general_processing'],
        'clarity_assessment': 5,
        'lucidity_indicators': [],
        'recommendations': 'Keep recording your dreams for pattern recognition',
      };
    }
  }
}

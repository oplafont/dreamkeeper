class Dream {
  final String id;
  final String userId;
  final String? title;
  final String content;
  final DateTime dreamDate;
  final String? sleepQuality;
  final String? dreamType;
  final String? mood;
  final List<String> tags;
  final bool isLucid;
  final bool isNightmare;
  final bool isRecurring;
  final int? clarityScore;
  final String? audioRecordingPath;
  final Map<String, dynamic>? aiAnalysis;
  final List<String> aiTags;
  final List<String> aiSymbols;
  final List<String> aiEmotions;
  final List<String> aiThemes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Dream({
    required this.id,
    required this.userId,
    this.title,
    required this.content,
    required this.dreamDate,
    this.sleepQuality,
    this.dreamType,
    this.mood,
    this.tags = const [],
    this.isLucid = false,
    this.isNightmare = false,
    this.isRecurring = false,
    this.clarityScore,
    this.audioRecordingPath,
    this.aiAnalysis,
    this.aiTags = const [],
    this.aiSymbols = const [],
    this.aiEmotions = const [],
    this.aiThemes = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Dream.fromJson(Map<String, dynamic> json) {
    return Dream(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      dreamDate: DateTime.parse(json['dream_date']),
      sleepQuality: json['sleep_quality'],
      dreamType: json['dream_type'],
      mood: json['mood'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isLucid: json['is_lucid'] ?? false,
      isNightmare: json['is_nightmare'] ?? false,
      isRecurring: json['is_recurring'] ?? false,
      clarityScore: json['clarity_score'],
      audioRecordingPath: json['audio_recording_path'],
      aiAnalysis: json['ai_analysis'],
      aiTags: json['ai_tags'] != null ? List<String>.from(json['ai_tags']) : [],
      aiSymbols: json['ai_symbols'] != null
          ? List<String>.from(json['ai_symbols'])
          : [],
      aiEmotions: json['ai_emotions'] != null
          ? List<String>.from(json['ai_emotions'])
          : [],
      aiThemes:
          json['ai_themes'] != null ? List<String>.from(json['ai_themes']) : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'dream_date': dreamDate.toIso8601String().split('T')[0],
      'sleep_quality': sleepQuality,
      'dream_type': dreamType,
      'mood': mood,
      'tags': tags,
      'is_lucid': isLucid,
      'is_nightmare': isNightmare,
      'is_recurring': isRecurring,
      'clarity_score': clarityScore,
      'audio_recording_path': audioRecordingPath,
      'ai_analysis': aiAnalysis,
      'ai_tags': aiTags,
      'ai_symbols': aiSymbols,
      'ai_emotions': aiEmotions,
      'ai_themes': aiThemes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Dream copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? dreamDate,
    String? sleepQuality,
    String? dreamType,
    String? mood,
    List<String>? tags,
    bool? isLucid,
    bool? isNightmare,
    bool? isRecurring,
    int? clarityScore,
    String? audioRecordingPath,
    Map<String, dynamic>? aiAnalysis,
    List<String>? aiTags,
    List<String>? aiSymbols,
    List<String>? aiEmotions,
    List<String>? aiThemes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dream(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      dreamDate: dreamDate ?? this.dreamDate,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      dreamType: dreamType ?? this.dreamType,
      mood: mood ?? this.mood,
      tags: tags ?? this.tags,
      isLucid: isLucid ?? this.isLucid,
      isNightmare: isNightmare ?? this.isNightmare,
      isRecurring: isRecurring ?? this.isRecurring,
      clarityScore: clarityScore ?? this.clarityScore,
      audioRecordingPath: audioRecordingPath ?? this.audioRecordingPath,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      aiTags: aiTags ?? this.aiTags,
      aiSymbols: aiSymbols ?? this.aiSymbols,
      aiEmotions: aiEmotions ?? this.aiEmotions,
      aiThemes: aiThemes ?? this.aiThemes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters for UI display
  String get displayTitle =>
      title?.isNotEmpty == true ? title! : 'Untitled Dream';

  String get moodEmoji {
    switch (mood) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'anxious':
        return '😰';
      case 'peaceful':
        return '😌';
      case 'confused':
        return '😵';
      case 'excited':
        return '🤩';
      case 'fearful':
        return '😨';
      default:
        return '😶';
    }
  }

  String get dreamTypeIcon {
    switch (dreamType) {
      case 'lucid':
        return '🌟';
      case 'nightmare':
        return '😱';
      case 'recurring':
        return '🔄';
      case 'prophetic':
        return '🔮';
      default:
        return '💭';
    }
  }

  String get sleepQualityIcon {
    switch (sleepQuality) {
      case 'excellent':
        return '😴';
      case 'good':
        return '😊';
      case 'fair':
        return '😐';
      case 'poor':
        return '😫';
      default:
        return '😶';
    }
  }

  bool get hasAIAnalysis => aiAnalysis != null && aiAnalysis!.isNotEmpty;
  bool get hasAudio => audioRecordingPath?.isNotEmpty == true;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(dreamDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dreamDate.day}/${dreamDate.month}/${dreamDate.year}';
    }
  }
}

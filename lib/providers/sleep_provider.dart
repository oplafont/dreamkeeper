import 'package:flutter/foundation.dart';

import '../services/logger_service.dart';
import '../services/supabase_service.dart';

/// Sleep tracking data model
class SleepSession {
  final String? id;
  final String userId;
  final DateTime sleepDate;
  final int durationMinutes;
  final String quality; // poor, fair, good, excellent
  final int? interruptions;
  final String? notes;
  final Map<String, dynamic>? environmentFactors;
  final DateTime? createdAt;

  SleepSession({
    this.id,
    required this.userId,
    required this.sleepDate,
    required this.durationMinutes,
    required this.quality,
    this.interruptions,
    this.notes,
    this.environmentFactors,
    this.createdAt,
  });

  factory SleepSession.fromJson(Map<String, dynamic> json) {
    return SleepSession(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      sleepDate: DateTime.parse(json['sleep_date'] as String),
      durationMinutes: json['duration_minutes'] as int,
      quality: json['quality'] as String,
      interruptions: json['interruptions'] as int?,
      notes: json['notes'] as String?,
      environmentFactors: json['environment_factors'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'sleep_date': sleepDate.toIso8601String().split('T')[0],
      'duration_minutes': durationMinutes,
      'quality': quality,
      if (interruptions != null) 'interruptions': interruptions,
      if (notes != null) 'notes': notes,
      if (environmentFactors != null) 'environment_factors': environmentFactors,
    };
  }

  double get durationHours => durationMinutes / 60.0;

  String get durationFormatted {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return '${hours}h ${mins}m';
  }

  String get qualityEmoji {
    switch (quality) {
      case 'excellent':
        return '4/4';
      case 'good':
        return '3/4';
      case 'fair':
        return '2/4';
      case 'poor':
        return '1/4';
      default:
        return '-';
    }
  }
}

/// Sleep tracking state provider
/// Manages sleep session data with Supabase persistence
class SleepProvider extends ChangeNotifier {
  final _client = SupabaseService.instance.client;

  List<SleepSession> _sessions = [];
  SleepSession? _todaySession;
  Map<String, dynamic>? _weeklyStats;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // Getters
  List<SleepSession> get sessions => _sessions;
  SleepSession? get todaySession => _todaySession;
  Map<String, dynamic>? get weeklyStats => _weeklyStats;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  double get averageSleepHours {
    if (_sessions.isEmpty) return 0;
    final total = _sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    return total / _sessions.length / 60.0;
  }

  String get dominantQuality {
    if (_sessions.isEmpty) return 'unknown';
    final counts = <String, int>{};
    for (final s in _sessions) {
      counts[s.quality] = (counts[s.quality] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Initialize and load sleep data
  Future<void> initialize() async {
    await loadSessions();
    await _loadTodaySession();
  }

  /// Load sleep sessions for the current user
  Future<void> loadSessions({int limit = 30}) async {
    _setLoading(true);
    _clearError();

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('sleep_sessions')
          .select()
          .eq('user_id', userId)
          .order('sleep_date', ascending: false)
          .limit(limit);

      _sessions = (response as List)
          .map((data) => SleepSession.fromJson(data as Map<String, dynamic>))
          .toList();

      log.info('Loaded ${_sessions.length} sleep sessions');
    } catch (e) {
      _setError('Failed to load sleep sessions: ${e.toString()}');
      log.error('Failed to load sleep sessions', e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadTodaySession() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _client
          .from('sleep_sessions')
          .select()
          .eq('user_id', userId)
          .eq('sleep_date', today)
          .maybeSingle();

      if (response != null) {
        _todaySession = SleepSession.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      log.warning('Failed to load today\'s sleep session', e);
    }
  }

  /// Save a sleep session
  Future<SleepSession?> saveSleepSession({
    required int durationMinutes,
    required String quality,
    int? interruptions,
    String? notes,
    Map<String, dynamic>? environmentFactors,
    DateTime? sleepDate,
  }) async {
    _setSaving(true);
    _clearError();

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final date = sleepDate ?? DateTime.now();
      final dateString = date.toIso8601String().split('T')[0];

      // Check if session already exists for this date
      final existing = await _client
          .from('sleep_sessions')
          .select()
          .eq('user_id', userId)
          .eq('sleep_date', dateString)
          .maybeSingle();

      Map<String, dynamic> sessionData = {
        'user_id': userId,
        'sleep_date': dateString,
        'duration_minutes': durationMinutes,
        'quality': quality,
        if (interruptions != null) 'interruptions': interruptions,
        if (notes != null) 'notes': notes,
        if (environmentFactors != null) 'environment_factors': environmentFactors,
      };

      Map<String, dynamic> response;

      if (existing != null) {
        // Update existing session
        response = await _client
            .from('sleep_sessions')
            .update(sessionData)
            .eq('id', existing['id'])
            .select()
            .single();
        log.info('Updated sleep session for $dateString');
      } else {
        // Insert new session
        response = await _client
            .from('sleep_sessions')
            .insert(sessionData)
            .select()
            .single();
        log.info('Created sleep session for $dateString');
      }

      final session = SleepSession.fromJson(response);

      // Update local state
      final index = _sessions.indexWhere(
        (s) => s.sleepDate.toIso8601String().split('T')[0] == dateString,
      );
      if (index != -1) {
        _sessions[index] = session;
      } else {
        _sessions.insert(0, session);
      }

      // Update today's session if applicable
      final todayString = DateTime.now().toIso8601String().split('T')[0];
      if (dateString == todayString) {
        _todaySession = session;
      }

      notifyListeners();
      return session;
    } catch (e) {
      _setError('Failed to save sleep session: ${e.toString()}');
      log.error('Failed to save sleep session', e);
      return null;
    } finally {
      _setSaving(false);
    }
  }

  /// Delete a sleep session
  Future<bool> deleteSleepSession(String sessionId) async {
    _setSaving(true);
    _clearError();

    try {
      await _client.from('sleep_sessions').delete().eq('id', sessionId);

      _sessions.removeWhere((s) => s.id == sessionId);
      if (_todaySession?.id == sessionId) {
        _todaySession = null;
      }

      notifyListeners();
      log.info('Deleted sleep session: $sessionId');
      return true;
    } catch (e) {
      _setError('Failed to delete sleep session: ${e.toString()}');
      log.error('Failed to delete sleep session', e);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// Get sleep sessions for a date range
  Future<List<SleepSession>> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('sleep_sessions')
          .select()
          .eq('user_id', userId)
          .gte('sleep_date', startDate.toIso8601String().split('T')[0])
          .lte('sleep_date', endDate.toIso8601String().split('T')[0])
          .order('sleep_date', ascending: true);

      return (response as List)
          .map((data) => SleepSession.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log.error('Failed to get sessions by date range', e);
      return [];
    }
  }

  /// Calculate weekly statistics
  Future<void> calculateWeeklyStats() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));

      final weeklySessions = await getSessionsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      if (weeklySessions.isEmpty) {
        _weeklyStats = null;
        notifyListeners();
        return;
      }

      final totalMinutes = weeklySessions.fold<int>(
        0,
        (sum, s) => sum + s.durationMinutes,
      );
      final avgMinutes = totalMinutes ~/ weeklySessions.length;

      final qualityCounts = <String, int>{};
      for (final s in weeklySessions) {
        qualityCounts[s.quality] = (qualityCounts[s.quality] ?? 0) + 1;
      }

      _weeklyStats = {
        'totalSessions': weeklySessions.length,
        'averageMinutes': avgMinutes,
        'averageHours': avgMinutes / 60.0,
        'qualityCounts': qualityCounts,
        'totalInterruptions': weeklySessions.fold<int>(
          0,
          (sum, s) => sum + (s.interruptions ?? 0),
        ),
      };

      notifyListeners();
    } catch (e) {
      log.error('Failed to calculate weekly stats', e);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}

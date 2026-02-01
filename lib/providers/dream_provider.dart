import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dream.dart';
import '../services/dream_service.dart';
import '../services/logger_service.dart';
import '../services/offline_service.dart';

/// Dream state provider
/// Manages dreams data and provides reactive updates
class DreamProvider extends ChangeNotifier {
  final DreamService _dreamService = DreamService();

  List<Dream> _dreams = [];
  Dream? _selectedDream;
  Map<DateTime, List<Dream>> _dreamsByDate = {};
  Map<String, dynamic>? _statistics;
  List<Map<String, dynamic>> _insights = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  RealtimeChannel? _realtimeChannel;

  // Getters
  List<Dream> get dreams => _dreams;
  Dream? get selectedDream => _selectedDream;
  Map<DateTime, List<Dream>> get dreamsByDate => _dreamsByDate;
  Map<String, dynamic>? get statistics => _statistics;
  List<Map<String, dynamic>> get insights => _insights;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get hasDreams => _dreams.isNotEmpty;
  int get dreamCount => _dreams.length;

  // Computed getters
  List<Dream> get recentDreams => _dreams.take(5).toList();

  List<Dream> get lucidDreams => _dreams.where((d) => d.isLucid).toList();

  List<Dream> get nightmares => _dreams.where((d) => d.isNightmare).toList();

  Map<String, int> get moodCounts {
    final counts = <String, int>{};
    for (final dream in _dreams) {
      if (dream.mood != null) {
        counts[dream.mood!] = (counts[dream.mood!] ?? 0) + 1;
      }
    }
    return counts;
  }

  double get averageClarityScore {
    final dreamsWithScore = _dreams.where((d) => d.clarityScore != null).toList();
    if (dreamsWithScore.isEmpty) return 0;
    return dreamsWithScore.map((d) => d.clarityScore!).reduce((a, b) => a + b) /
        dreamsWithScore.length;
  }

  /// Initialize and load dreams
  Future<void> initialize() async {
    // Initialize offline service
    await offlineService.initialize();

    // Set up connectivity change handler
    offlineService.onConnectivityChanged = _handleConnectivityChange;
    offlineService.onPendingOperationsSync = _syncPendingOperations;

    // Load dreams (with offline fallback)
    await loadDreams();
    _setupRealtimeSubscription();
  }

  void _handleConnectivityChange(bool isOnline) {
    log.info('Connectivity changed: ${isOnline ? "Online" : "Offline"}');
    notifyListeners();
  }

  Future<void> _syncPendingOperations() async {
    if (!offlineService.hasPendingOperations) return;

    log.info('Syncing ${offlineService.pendingOperationsCount} pending operations');

    final operations = offlineService.getPendingOperations();

    for (final op in operations) {
      try {
        switch (op.type) {
          case OfflineOperationType.createDream:
            await _dreamService.createDream(
              content: op.data['content'] as String,
              title: op.data['title'] as String?,
              mood: op.data['mood'] as String?,
              tags: (op.data['tags'] as List?)?.cast<String>(),
            );
            break;
          case OfflineOperationType.updateDream:
            await _dreamService.updateDream(
              op.data['dreamId'] as String,
              op.data['updates'] as Map<String, dynamic>,
            );
            break;
          case OfflineOperationType.deleteDream:
            await _dreamService.deleteDream(op.data['dreamId'] as String);
            break;
          case OfflineOperationType.saveSleepSession:
            // Handle sleep session sync if needed
            break;
        }

        await offlineService.removeOperation(op.id);
        log.debug('Synced operation: ${op.type.name}');
      } catch (e) {
        log.error('Failed to sync operation: ${op.type.name}', e);
      }
    }

    // Reload dreams after sync
    await loadDreams();
  }

  /// Load all dreams for the current user
  Future<void> loadDreams({
    int limit = 50,
    String? dreamType,
    String? mood,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if we're online
      if (offlineService.isOnline) {
        final dreamsData = await _dreamService.getUserDreams(
          limit: limit,
          dreamType: dreamType,
          mood: mood,
          startDate: startDate,
          endDate: endDate,
        );

        _dreams = dreamsData.map((data) => Dream.fromJson(data)).toList();

        // Cache for offline use
        await offlineService.cacheDreamsForOffline(dreamsData);

        log.info('Loaded ${_dreams.length} dreams from server');
      } else {
        // Load from offline cache
        final cachedData = await offlineService.getOfflineCachedDreams();
        if (cachedData != null) {
          _dreams = cachedData.map((data) => Dream.fromJson(data)).toList();
          log.info('Loaded ${_dreams.length} dreams from offline cache');
        } else {
          _setError('No cached dreams available offline');
        }
      }

      _organizeDreamsByDate();
    } catch (e) {
      // Try offline cache as fallback
      log.warning('Online load failed, trying offline cache');
      final cachedData = await offlineService.getOfflineCachedDreams();
      if (cachedData != null) {
        _dreams = cachedData.map((data) => Dream.fromJson(data)).toList();
        _organizeDreamsByDate();
        log.info('Loaded ${_dreams.length} dreams from offline cache (fallback)');
      } else {
        _setError('Failed to load dreams: ${e.toString()}');
        log.error('Failed to load dreams', e);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Load a single dream by ID
  Future<Dream?> loadDream(String dreamId) async {
    _setLoading(true);
    _clearError();

    try {
      final dreamData = await _dreamService.getDreamById(dreamId);
      if (dreamData != null) {
        _selectedDream = Dream.fromJson(dreamData);
        notifyListeners();
        return _selectedDream;
      }
      return null;
    } catch (e) {
      _setError('Failed to load dream: ${e.toString()}');
      log.error('Failed to load dream $dreamId', e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new dream
  Future<Dream?> createDream({
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
    _setSaving(true);
    _clearError();

    try {
      final dreamData = await _dreamService.createDream(
        content: content,
        title: title,
        mood: mood,
        tags: tags,
        dreamType: dreamType,
        sleepQuality: sleepQuality,
        isLucid: isLucid,
        isNightmare: isNightmare,
        isRecurring: isRecurring,
        clarityScore: clarityScore,
        performAIAnalysis: performAIAnalysis,
      );

      final newDream = Dream.fromJson(dreamData);
      _dreams.insert(0, newDream);
      _organizeDreamsByDate();

      log.info('Created dream: ${newDream.id}');
      return newDream;
    } catch (e) {
      _setError('Failed to create dream: ${e.toString()}');
      log.error('Failed to create dream', e);
      return null;
    } finally {
      _setSaving(false);
    }
  }

  /// Create a dream from audio recording
  Future<Dream?> createDreamFromAudio({
    required File audioFile,
    String? title,
    String? mood,
    List<String>? tags,
  }) async {
    _setSaving(true);
    _clearError();

    try {
      final dreamData = await _dreamService.createDreamFromAudio(
        audioFile: audioFile,
        title: title,
        mood: mood,
        tags: tags,
      );

      final newDream = Dream.fromJson(dreamData);
      _dreams.insert(0, newDream);
      _organizeDreamsByDate();

      log.info('Created dream from audio: ${newDream.id}');
      return newDream;
    } catch (e) {
      _setError('Failed to create dream from audio: ${e.toString()}');
      log.error('Failed to create dream from audio', e);
      return null;
    } finally {
      _setSaving(false);
    }
  }

  /// Update an existing dream
  Future<Dream?> updateDream(String dreamId, Map<String, dynamic> updates) async {
    _setSaving(true);
    _clearError();

    try {
      final dreamData = await _dreamService.updateDream(dreamId, updates);
      final updatedDream = Dream.fromJson(dreamData);

      // Update in list
      final index = _dreams.indexWhere((d) => d.id == dreamId);
      if (index != -1) {
        _dreams[index] = updatedDream;
      }

      // Update selected dream if it matches
      if (_selectedDream?.id == dreamId) {
        _selectedDream = updatedDream;
      }

      _organizeDreamsByDate();
      log.info('Updated dream: $dreamId');
      return updatedDream;
    } catch (e) {
      _setError('Failed to update dream: ${e.toString()}');
      log.error('Failed to update dream $dreamId', e);
      return null;
    } finally {
      _setSaving(false);
    }
  }

  /// Delete a dream
  Future<bool> deleteDream(String dreamId) async {
    _setSaving(true);
    _clearError();

    try {
      await _dreamService.deleteDream(dreamId);

      _dreams.removeWhere((d) => d.id == dreamId);
      if (_selectedDream?.id == dreamId) {
        _selectedDream = null;
      }

      _organizeDreamsByDate();
      log.info('Deleted dream: $dreamId');
      return true;
    } catch (e) {
      _setError('Failed to delete dream: ${e.toString()}');
      log.error('Failed to delete dream $dreamId', e);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// Search dreams
  Future<List<Dream>> searchDreams({
    required String searchTerm,
    List<String>? tagFilters,
    List<String>? moodFilters,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final dreamsData = await _dreamService.searchDreams(
        searchTerm: searchTerm,
        tagFilters: tagFilters,
        moodFilters: moodFilters,
      );

      return dreamsData.map((data) => Dream.fromJson(data)).toList();
    } catch (e) {
      _setError('Failed to search dreams: ${e.toString()}');
      log.error('Failed to search dreams', e);
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Load dreams for a date range (calendar view)
  Future<void> loadDreamsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final dreamsData = await _dreamService.getDreamsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      final dreams = dreamsData.map((data) => Dream.fromJson(data)).toList();

      // Organize by date
      _dreamsByDate.clear();
      for (final dream in dreams) {
        final date = DateTime(
          dream.dreamDate.year,
          dream.dreamDate.month,
          dream.dreamDate.day,
        );
        _dreamsByDate.putIfAbsent(date, () => []).add(dream);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load dreams by date range: ${e.toString()}');
      log.error('Failed to load dreams by date range', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Load dream statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _dreamService.getDreamStatistics();
      notifyListeners();
    } catch (e) {
      log.warning('Failed to load dream statistics', e);
    }
  }

  /// Generate AI insights
  Future<String?> generateInsights({
    required String insightType,
    int dreamCount = 10,
  }) async {
    _setLoading(true);

    try {
      final insight = await _dreamService.generateDreamInsights(
        insightType: insightType,
        dreamCount: dreamCount,
      );
      return insight;
    } catch (e) {
      log.error('Failed to generate insights', e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Load user insights
  Future<void> loadInsights({int limit = 20}) async {
    try {
      _insights = await _dreamService.getUserInsights(limit: limit);
      notifyListeners();
    } catch (e) {
      log.warning('Failed to load insights', e);
    }
  }

  /// Select a dream for detail view
  void selectDream(Dream? dream) {
    _selectedDream = dream;
    notifyListeners();
  }

  /// Get dreams for a specific date
  List<Dream> getDreamsForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _dreamsByDate[normalizedDate] ?? [];
  }

  void _organizeDreamsByDate() {
    _dreamsByDate.clear();
    for (final dream in _dreams) {
      final date = DateTime(
        dream.dreamDate.year,
        dream.dreamDate.month,
        dream.dreamDate.day,
      );
      _dreamsByDate.putIfAbsent(date, () => []).add(dream);
    }
    notifyListeners();
  }

  void _setupRealtimeSubscription() {
    _realtimeChannel = _dreamService.subscribeToNewDreams(
      onNewDream: (data) {
        final newDream = Dream.fromJson(data);
        if (!_dreams.any((d) => d.id == newDream.id)) {
          _dreams.insert(0, newDream);
          _organizeDreamsByDate();
        }
      },
      onDreamUpdated: (data) {
        final updatedDream = Dream.fromJson(data);
        final index = _dreams.indexWhere((d) => d.id == updatedDream.id);
        if (index != -1) {
          _dreams[index] = updatedDream;
          _organizeDreamsByDate();
        }
      },
      onDreamDeleted: (data) {
        final deletedId = data['id'] as String?;
        if (deletedId != null) {
          _dreams.removeWhere((d) => d.id == deletedId);
          _organizeDreamsByDate();
        }
      },
    );
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

  /// Clear error state
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';

/// Offline operation type
enum OfflineOperationType {
  createDream,
  updateDream,
  deleteDream,
  saveSleepSession,
}

/// Pending offline operation
class OfflineOperation {
  final String id;
  final OfflineOperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      type: OfflineOperationType.values[json['type'] as int],
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Service for managing offline operations and connectivity
class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  static OfflineService get instance => _instance;

  OfflineService._internal();

  static const String _offlineQueueKey = 'offline_operation_queue';
  static const String _offlineCacheKey = 'offline_dream_cache';
  static const String _lastSyncKey = 'last_sync_timestamp';

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = true;
  final List<OfflineOperation> _pendingOperations = [];

  // Callbacks
  Function(bool isOnline)? onConnectivityChanged;
  Function()? onPendingOperationsSync;

  bool get isOnline => _isOnline;
  int get pendingOperationsCount => _pendingOperations.length;
  bool get hasPendingOperations => _pendingOperations.isNotEmpty;

  /// Initialize the offline service
  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);

    // Load pending operations from storage
    await _loadPendingOperations();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );

    log.info('OfflineService initialized. Online: $_isOnline, Pending: ${_pendingOperations.length}');
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = !results.contains(ConnectivityResult.none);

    if (_isOnline != wasOnline) {
      log.info('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
      onConnectivityChanged?.call(_isOnline);

      // If we just came online and have pending operations, sync them
      if (_isOnline && _pendingOperations.isNotEmpty) {
        onPendingOperationsSync?.call();
      }
    }
  }

  /// Queue an operation for offline execution
  Future<void> queueOperation(OfflineOperation operation) async {
    _pendingOperations.add(operation);
    await _savePendingOperations();
    log.debug('Queued offline operation: ${operation.type.name}');
  }

  /// Queue a dream creation for offline
  Future<void> queueCreateDream(Map<String, dynamic> dreamData) async {
    final operation = OfflineOperation(
      id: 'create_${DateTime.now().millisecondsSinceEpoch}',
      type: OfflineOperationType.createDream,
      data: dreamData,
      createdAt: DateTime.now(),
    );
    await queueOperation(operation);
  }

  /// Queue a dream update for offline
  Future<void> queueUpdateDream(String dreamId, Map<String, dynamic> updates) async {
    final operation = OfflineOperation(
      id: 'update_${DateTime.now().millisecondsSinceEpoch}',
      type: OfflineOperationType.updateDream,
      data: {'dreamId': dreamId, 'updates': updates},
      createdAt: DateTime.now(),
    );
    await queueOperation(operation);
  }

  /// Queue a dream deletion for offline
  Future<void> queueDeleteDream(String dreamId) async {
    final operation = OfflineOperation(
      id: 'delete_${DateTime.now().millisecondsSinceEpoch}',
      type: OfflineOperationType.deleteDream,
      data: {'dreamId': dreamId},
      createdAt: DateTime.now(),
    );
    await queueOperation(operation);
  }

  /// Get all pending operations
  List<OfflineOperation> getPendingOperations() {
    return List.unmodifiable(_pendingOperations);
  }

  /// Remove a pending operation (after successful sync)
  Future<void> removeOperation(String operationId) async {
    _pendingOperations.removeWhere((op) => op.id == operationId);
    await _savePendingOperations();
  }

  /// Clear all pending operations
  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    await _savePendingOperations();
  }

  /// Cache dreams for offline access
  Future<void> cacheDreamsForOffline(List<Map<String, dynamic>> dreams) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(dreams);
      await prefs.setString(_offlineCacheKey, jsonString);
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      log.debug('Cached ${dreams.length} dreams for offline access');
    } catch (e) {
      log.error('Failed to cache dreams for offline', e);
    }
  }

  /// Get offline cached dreams
  Future<List<Map<String, dynamic>>?> getOfflineCachedDreams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_offlineCacheKey);

      if (jsonString == null) return null;

      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      log.error('Failed to get offline cached dreams', e);
      return null;
    }
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastSyncKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Check if offline cache is stale (older than 24 hours)
  Future<bool> isOfflineCacheStale() async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;

    final difference = DateTime.now().difference(lastSync);
    return difference.inHours > 24;
  }

  Future<void> _loadPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_offlineQueueKey);

      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _pendingOperations.clear();
        _pendingOperations.addAll(
          decoded.map((item) => OfflineOperation.fromJson(item as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      log.error('Failed to load pending operations', e);
    }
  }

  Future<void> _savePendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_pendingOperations.map((op) => op.toJson()).toList());
      await prefs.setString(_offlineQueueKey, jsonString);
    } catch (e) {
      log.error('Failed to save pending operations', e);
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

/// Global offline service instance
final offlineService = OfflineService.instance;

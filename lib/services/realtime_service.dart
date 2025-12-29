import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

/// Centralized real-time subscription management service
class RealtimeService {
  final client = SupabaseService.instance.client;
  final Map<String, RealtimeChannel> _channels = {};

  /// Subscribe to new dream submissions in real-time
  /// Returns a channel that can be used to unsubscribe later
  RealtimeChannel subscribeToDreams({
    required Function(Map<String, dynamic>) onInsert,
    Function(Map<String, dynamic>)? onUpdate,
    Function(Map<String, dynamic>)? onDelete,
    String? channelName,
  }) {
    final channel = client.channel(
        channelName ?? 'dreams-${DateTime.now().millisecondsSinceEpoch}');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'dreams',
          callback: (payload) {
            final newDream = payload.newRecord;
            onInsert(newDream);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'dreams',
          callback: (payload) {
            if (onUpdate != null) {
              final updatedDream = payload.newRecord;
              onUpdate(updatedDream);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'dreams',
          callback: (payload) {
            if (onDelete != null) {
              final deletedDream = payload.oldRecord;
              onDelete(deletedDream);
            }
          },
        )
        .subscribe();

    _channels[channelName ?? 'dreams-default'] = channel;
    return channel;
  }

  /// Subscribe to engagement summary updates in real-time
  /// This tracks changes to user engagement metrics
  RealtimeChannel subscribeToEngagement({
    required Function(Map<String, dynamic>) onUpdate,
    String? channelName,
  }) {
    final channel = client.channel(
        channelName ?? 'engagement-${DateTime.now().millisecondsSinceEpoch}');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'user_engagement_summary',
          callback: (payload) {
            final updatedEngagement = payload.newRecord;
            onUpdate(updatedEngagement);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'user_engagement_summary',
          callback: (payload) {
            final newEngagement = payload.newRecord;
            onUpdate(newEngagement);
          },
        )
        .subscribe();

    _channels[channelName ?? 'engagement-default'] = channel;
    return channel;
  }

  /// Subscribe to specific dream updates by ID
  RealtimeChannel subscribeToDreamById({
    required String dreamId,
    required Function(Map<String, dynamic>) onUpdate,
    Function(Map<String, dynamic>)? onDelete,
    String? channelName,
  }) {
    final channel = client.channel(channelName ?? 'dream-$dreamId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'dreams',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: dreamId,
          ),
          callback: (payload) {
            final updatedDream = payload.newRecord;
            onUpdate(updatedDream);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'dreams',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: dreamId,
          ),
          callback: (payload) {
            if (onDelete != null) {
              final deletedDream = payload.oldRecord;
              onDelete(deletedDream);
            }
          },
        )
        .subscribe();

    _channels[channelName ?? 'dream-$dreamId'] = channel;
    return channel;
  }

  /// Subscribe to dreams filtered by category
  RealtimeChannel subscribeToDreamsByCategory({
    required String category,
    required Function(Map<String, dynamic>) onInsert,
    Function(Map<String, dynamic>)? onUpdate,
    String? channelName,
  }) {
    final channel = client.channel(channelName ?? 'dreams-category-$category');

    // Note: Supabase realtime doesn't support complex filters directly
    // We'll receive all dream changes and filter in the callback
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'dreams',
          callback: (payload) {
            final newDream = payload.newRecord;
            // Filter by category in callback
            if (_matchesCategory(newDream, category)) {
              onInsert(newDream);
            }
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'dreams',
          callback: (payload) {
            if (onUpdate != null) {
              final updatedDream = payload.newRecord;
              if (_matchesCategory(updatedDream, category)) {
                onUpdate(updatedDream);
              }
            }
          },
        )
        .subscribe();

    _channels[channelName ?? 'dreams-category-$category'] = channel;
    return channel;
  }

  /// Helper method to check if a dream matches a category filter
  bool _matchesCategory(Map<String, dynamic> dream, String category) {
    switch (category) {
      case 'lucid':
        return dream['is_lucid'] == true;
      case 'nightmares':
        return dream['is_nightmare'] == true;
      case 'recurring':
        return dream['is_recurring'] == true;
      case 'prophetic':
        return dream['dream_type'] == 'prophetic';
      case 'all':
      default:
        return true;
    }
  }

  /// Unsubscribe from a specific channel
  Future<void> unsubscribe(String channelName) async {
    final channel = _channels[channelName];
    if (channel != null) {
      await client.removeChannel(channel);
      _channels.remove(channelName);
    }
  }

  /// Unsubscribe from all channels
  Future<void> unsubscribeAll() async {
    for (final channel in _channels.values) {
      await client.removeChannel(channel);
    }
    _channels.clear();
  }

  /// Get active channel names
  List<String> getActiveChannels() {
    return _channels.keys.toList();
  }

  /// Check if a specific channel is active
  bool isChannelActive(String channelName) {
    return _channels.containsKey(channelName);
  }
}

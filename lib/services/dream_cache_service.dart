import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DreamCacheService {
  static const String _cachePrefix = 'dream_cache_';
  static const String _timestampPrefix = 'dream_timestamp_';
  static const Duration _cacheDuration = Duration(minutes: 15);

  /// Save dreams to cache with timestamp
  static Future<void> cacheDreams(
    String cacheKey,
    List<Map<String, dynamic>> dreams,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(dreams);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString('$_cachePrefix$cacheKey', jsonString);
      await prefs.setInt('$_timestampPrefix$cacheKey', timestamp);
    } catch (e) {
      print('Cache save failed: $e');
    }
  }

  /// Get dreams from cache if not expired
  static Future<List<Map<String, dynamic>>?> getCachedDreams(
    String cacheKey,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_cachePrefix$cacheKey');
      final timestamp = prefs.getInt('$_timestampPrefix$cacheKey');

      if (jsonString == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      if (difference > _cacheDuration) {
        // Cache expired, clear it
        await clearCache(cacheKey);
        return null;
      }

      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Cache retrieval failed: $e');
      return null;
    }
  }

  /// Clear specific cache
  static Future<void> clearCache(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$cacheKey');
      await prefs.remove('$_timestampPrefix$cacheKey');
    } catch (e) {
      print('Cache clear failed: $e');
    }
  }

  /// Clear all dream caches
  static Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Clear all caches failed: $e');
    }
  }

  /// Check if cache exists and is valid
  static Future<bool> isCacheValid(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('$_timestampPrefix$cacheKey');

      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      return difference <= _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  /// Invalidate a specific cache entry
  static Future<void> invalidateCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('dreams_$key');
      await prefs.remove('timestamp_$key');
      print('Cache invalidated for key: $key');
    } catch (e) {
      print('Failed to invalidate cache: $e');
    }
  }

  /// Generate cache key from filters
  static String generateCacheKey({
    required String category,
    required String sortOption,
    String? searchText,
    Map<String, dynamic>? filters,
  }) {
    final parts = [
      category,
      sortOption,
      searchText ?? '',
      filters?.toString() ?? '',
    ];
    return parts.join('_').replaceAll(RegExp(r'[^\w\s]+'), '');
  }
}

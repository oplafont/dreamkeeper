import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/logger_service.dart';

/// Settings state provider
/// Manages app settings and user preferences with persistence
class SettingsProvider extends ChangeNotifier {
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyBedtimeReminder = 'bedtime_reminder';
  static const String _keyBedtimeHour = 'bedtime_hour';
  static const String _keyBedtimeMinute = 'bedtime_minute';
  static const String _keyMorningReminderEnabled = 'morning_reminder_enabled';
  static const String _keyMorningReminderHour = 'morning_reminder_hour';
  static const String _keyMorningReminderMinute = 'morning_reminder_minute';
  static const String _keyAutoAnalysis = 'auto_analysis';
  static const String _keyPrivateByDefault = 'private_by_default';
  static const String _keyVoiceRecordingEnabled = 'voice_recording_enabled';
  static const String _keyHapticFeedback = 'haptic_feedback';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';

  SharedPreferences? _prefs;
  bool _isLoading = true;

  // Default values
  bool _notificationsEnabled = true;
  bool _bedtimeReminder = false;
  int _bedtimeHour = 22;
  int _bedtimeMinute = 0;
  bool _morningReminderEnabled = true;
  int _morningReminderHour = 7;
  int _morningReminderMinute = 30;
  bool _autoAnalysis = true;
  bool _privateByDefault = true;
  bool _voiceRecordingEnabled = true;
  bool _hapticFeedback = true;
  String _themeMode = 'dark';
  String _language = 'en';

  // Getters
  bool get isLoading => _isLoading;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get bedtimeReminder => _bedtimeReminder;
  int get bedtimeHour => _bedtimeHour;
  int get bedtimeMinute => _bedtimeMinute;
  bool get morningReminderEnabled => _morningReminderEnabled;
  int get morningReminderHour => _morningReminderHour;
  int get morningReminderMinute => _morningReminderMinute;
  bool get autoAnalysis => _autoAnalysis;
  bool get privateByDefault => _privateByDefault;
  bool get voiceRecordingEnabled => _voiceRecordingEnabled;
  bool get hapticFeedback => _hapticFeedback;
  String get themeMode => _themeMode;
  String get language => _language;

  String get bedtimeFormatted {
    final hour = _bedtimeHour.toString().padLeft(2, '0');
    final minute = _bedtimeMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get morningReminderFormatted {
    final hour = _morningReminderHour.toString().padLeft(2, '0');
    final minute = _morningReminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Initialize settings from shared preferences
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadSettings();
      _isLoading = false;
      notifyListeners();
      log.info('Settings initialized');
    } catch (e) {
      log.error('Failed to initialize settings', e);
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadSettings() {
    _notificationsEnabled = _prefs?.getBool(_keyNotificationsEnabled) ?? true;
    _bedtimeReminder = _prefs?.getBool(_keyBedtimeReminder) ?? false;
    _bedtimeHour = _prefs?.getInt(_keyBedtimeHour) ?? 22;
    _bedtimeMinute = _prefs?.getInt(_keyBedtimeMinute) ?? 0;
    _morningReminderEnabled = _prefs?.getBool(_keyMorningReminderEnabled) ?? true;
    _morningReminderHour = _prefs?.getInt(_keyMorningReminderHour) ?? 7;
    _morningReminderMinute = _prefs?.getInt(_keyMorningReminderMinute) ?? 30;
    _autoAnalysis = _prefs?.getBool(_keyAutoAnalysis) ?? true;
    _privateByDefault = _prefs?.getBool(_keyPrivateByDefault) ?? true;
    _voiceRecordingEnabled = _prefs?.getBool(_keyVoiceRecordingEnabled) ?? true;
    _hapticFeedback = _prefs?.getBool(_keyHapticFeedback) ?? true;
    _themeMode = _prefs?.getString(_keyThemeMode) ?? 'dark';
    _language = _prefs?.getString(_keyLanguage) ?? 'en';
  }

  // Setters with persistence

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _prefs?.setBool(_keyNotificationsEnabled, value);
    notifyListeners();
  }

  Future<void> setBedtimeReminder(bool value) async {
    _bedtimeReminder = value;
    await _prefs?.setBool(_keyBedtimeReminder, value);
    notifyListeners();
  }

  Future<void> setBedtime(int hour, int minute) async {
    _bedtimeHour = hour;
    _bedtimeMinute = minute;
    await _prefs?.setInt(_keyBedtimeHour, hour);
    await _prefs?.setInt(_keyBedtimeMinute, minute);
    notifyListeners();
  }

  Future<void> setMorningReminderEnabled(bool value) async {
    _morningReminderEnabled = value;
    await _prefs?.setBool(_keyMorningReminderEnabled, value);
    notifyListeners();
  }

  Future<void> setMorningReminder(int hour, int minute) async {
    _morningReminderHour = hour;
    _morningReminderMinute = minute;
    await _prefs?.setInt(_keyMorningReminderHour, hour);
    await _prefs?.setInt(_keyMorningReminderMinute, minute);
    notifyListeners();
  }

  Future<void> setAutoAnalysis(bool value) async {
    _autoAnalysis = value;
    await _prefs?.setBool(_keyAutoAnalysis, value);
    notifyListeners();
  }

  Future<void> setPrivateByDefault(bool value) async {
    _privateByDefault = value;
    await _prefs?.setBool(_keyPrivateByDefault, value);
    notifyListeners();
  }

  Future<void> setVoiceRecordingEnabled(bool value) async {
    _voiceRecordingEnabled = value;
    await _prefs?.setBool(_keyVoiceRecordingEnabled, value);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    await _prefs?.setBool(_keyHapticFeedback, value);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs?.setString(_keyThemeMode, mode);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _prefs?.setString(_keyLanguage, lang);
    notifyListeners();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await _prefs?.clear();
    _notificationsEnabled = true;
    _bedtimeReminder = false;
    _bedtimeHour = 22;
    _bedtimeMinute = 0;
    _morningReminderEnabled = true;
    _morningReminderHour = 7;
    _morningReminderMinute = 30;
    _autoAnalysis = true;
    _privateByDefault = true;
    _voiceRecordingEnabled = true;
    _hapticFeedback = true;
    _themeMode = 'dark';
    _language = 'en';
    notifyListeners();
    log.info('Settings reset to defaults');
  }
}

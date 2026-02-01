import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logging service for the app
/// Replaces scattered print() statements with structured logging
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  static LoggerService get instance => _instance;

  late final Logger _logger;

  LoggerService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: kDebugMode ? Level.debug : Level.warning,
    );
  }

  /// Log debug messages (only in debug mode)
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info messages
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning messages
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error messages
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal/critical errors
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

/// Global logger instance for easy access
final log = LoggerService.instance;

import 'package:flutter/foundation.dart';

/// Simple logger service for the Bible bot app
class AppLogger {
  static const String _tag = 'BijbelBot';

  /// Log info messages
  static void info(String message) {
    debugPrint('$_tag INFO: $message');
  }

  /// Log warning messages
  static void warning(String message) {
    debugPrint('$_tag WARNING: $message');
  }

  /// Log error messages
  static void error(String message, [Object? error]) {
    debugPrint('$_tag ERROR: $message');
    if (error != null) {
      debugPrint('$_tag ERROR DETAILS: $error');
    }
  }

  /// Log debug messages
  static void debug(String message) {
    debugPrint('$_tag DEBUG: $message');
  }
}
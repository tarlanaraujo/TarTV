import 'package:flutter/foundation.dart';

/// Simple application logger with level filtering.
/// Logs only in debug/profile builds to avoid leaking in release.
class AppLogger {
  AppLogger._();

  static void d(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[D][$tag] $message');
    }
  }

  static void i(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[I][$tag] $message');
    }
  }

  static void w(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[W][$tag] $message');
    }
  }

  static void e(String tag, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[E][$tag] $error');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}

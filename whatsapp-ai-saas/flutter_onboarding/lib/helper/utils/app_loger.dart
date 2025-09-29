import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static const String defaultTag = "MyMobiForce";
  static const String sync = "MobileSync";
  static const String api = "ApiCall";

  static void log(
      String message, {
        String tag = defaultTag,
        Object? error,
        StackTrace? stackTrace,
      }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void debug(String message, {String tag = defaultTag}) {
    if (kDebugMode) {
      print("[✅ $tag-DEBUG] $message");
    }
  }

  static void info(String message, {String tag = defaultTag}) {
    if (kDebugMode) {
      print("[ℹ️ $tag-INFO] $message");
    }
  }

  static void error(String message,
      {String tag = defaultTag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        "[❌ $tag-ERROR] $message",
        name: tag,
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }
}

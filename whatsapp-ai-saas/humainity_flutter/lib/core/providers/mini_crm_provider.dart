import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:humainity_flutter/repositories/mini_crm_repository.dart';

// Use AutoDispose to ensure we reset logic when leaving the screen
final miniCrmLinkProvider = AsyncNotifierProvider.autoDispose<MiniCrmLinkNotifier, String>(() {
  return MiniCrmLinkNotifier();
});

class MiniCrmLinkNotifier extends AutoDisposeAsyncNotifier<String> {
  // The target URL we ultimately want the user to see
  final String _targetUrl = 'http://localhost:8090/app/crm?embed=1';

  @override
  FutureOr<String> build() async {
    return _resolveSessionAndGetUrl();
  }

  /// Checks session status and decides whether to load Home or a Magic Link
  Future<String> _resolveSessionAndGetUrl() async {
    // 1. Check if the current session is active (Ping Home Page)
    final isSessionActive = await _checkSessionActive(_targetUrl);

    if (isSessionActive) {
      print("CRM Session is active. Loading Home URL directly.");
      return _targetUrl;
    } else {
      print("CRM Session inactive (403). Fetching NEW Magic Link...");
      return await _fetchNewMagicLink();
    }
  }

  Future<String> _fetchNewMagicLink() async {
    final repo = ref.read(miniCrmRepositoryProvider);
    // This fetches a NEW, FRESH magic link from the server.
    // Loading this in the iframe will set the cookie and redirect to /app/home.
    return await repo.getMagicLink();
  }

  /// Pings the ERP Home page to check if we are logged in.
  Future<bool> _checkSessionActive(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      // 200 means we have access
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Forces a complete refresh of the link logic.
  /// Call this when the "Refresh" button is clicked.
  Future<void> refreshLink() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      print("Manual Refresh: Forcing new Magic Link generation...");
      // On manual refresh, we skip the check and force a new Magic Link
      // to ensure we repair any broken session state.
      return await _fetchNewMagicLink();
    });
  }
}
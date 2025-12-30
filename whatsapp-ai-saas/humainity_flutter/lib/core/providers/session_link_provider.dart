import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:humainise_ai/repositories/mini_crm_repository.dart';

// General provider for handling session-based iframe links
final sessionLinkProvider =
    AsyncNotifierProvider.autoDispose<SessionLinkNotifier, void>(() {
  return SessionLinkNotifier();
});

class SessionLinkNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No initial state
  }

  /// Determines the URL to load.
  /// 1. Pings the [fullTargetUrl] to check session (200 OK).
  /// 2. If Active: Returns [fullTargetUrl].
  /// 3. If Inactive (403): Fetches Magic Link, appends redirect, returns that.
  Future<String> getUrlToLoad(String fullTargetUrl) async {
    // 1. Check if session is alive for the specific target
    final isSessionActive = await _checkUrlStatus(fullTargetUrl);

    if (isSessionActive) {
      print("Session active for $fullTargetUrl. Loading directly.");
      return fullTargetUrl;
    } else {
      print("Session inactive (403). Fetching Magic Link...");
      final repo = ref.read(miniCrmRepositoryProvider);

      // 2. Get the Magic Link (Login URL)
      String magicLink = await repo.getMagicLink();

      // 3. Append Redirect to the target URL
      // Ensure we extract the path from the full URL for the redirect param if needed,
      // but usually redirect-to takes a relative path or full path depending on the system.
      // Assuming ERPNext expects a relative path starting with /
      Uri uri = Uri.parse(fullTargetUrl);
      String redirectPath = uri.path;
      if (uri.hasQuery) {
        redirectPath += '?${uri.query}';
      }

      final separator = magicLink.contains('?') ? '&' : '?';
      final redirectLink = '$magicLink${separator}redirect-to=$redirectPath';

      print("Redirecting via: $redirectLink");
      return redirectLink;
    }
  }

  Future<bool> _checkUrlStatus(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as api;
import 'package:humainity_flutter/core/storage/store_user_data.dart';

// --- 1. Repository Provider ---
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Get the initialized store service
  final storeUserData = ref.watch(storeUserDataProvider);
  return AuthRepository(storeUserData);
});

// --- 2. Repository Class ---

class AuthRepository {
  final StoreUserData? _store;
  AuthRepository(this._store);

  bool _isFetchingOnboarding = false;
  bool _onboardingCompleted = false;
  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('Missing API_BASE_URL in .env');
    }
    return url;
  }

  // NEW: For App Hydration - Check if a token is present
  Future<bool> getAuthStatus() async {
    final token = await _store!.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> signIn(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _handleAuthResponse(data);
    } else {
      throw Exception(_safeError(res, 'Login failed'));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String businessName,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/signup');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'business_name': businessName,
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _handleAuthResponse(data);
    } else {
      throw Exception(_safeError(res, 'Signup failed'));
    }
  }

  Future<void> socialSignIn({
    required String idToken,
    required String provider,
    required bool isLogin,
  }) async {
    final url = Uri.parse('$_baseUrl/social_auth/login');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_token': idToken,
        'provider': provider,
        'is_login': isLogin,
        'plan': null,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await _handleAuthResponse(data);
    } else if (res.statusCode == 401) {
      throw Exception('Unauthorized access. Please check your credentials.');
    } else {
      throw Exception(_safeError(res, 'Social sign-in failed'));
    }
  }

  Future<void> signOut() async {
    await _store!.clear();
  }

   Future<Map<String, dynamic>> getOnboardingStatus(int tenantId) async {
    // Avoid duplicate calls and stop once we're done
    if (_isFetchingOnboarding || _onboardingCompleted) {
      return {};
    }

    _isFetchingOnboarding = true;
    try {
      final url = Uri.parse(
        '$_baseUrl/onboarding/get_onboarding_status?tenant_id=$tenantId',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      final status = Map<String, dynamic>.from(decoded);

      final process = status['onboarding_process']?.toString();

      if (process != null) {
        await _store?.setOnboardingProcess(process);
        if (process == 'Completed') {
          _onboardingCompleted = true;
        }
      }

      final stepsRaw = status['onboarding_steps'];
      if (stepsRaw is Map<String, dynamic>) {
        await _store?.saveOnboardingSteps(
          Map<String, dynamic>.from(stepsRaw),
        );
      }

      return status;
    } catch (e) {
      throw Exception('Failed to fetch onboarding status: $e');
    } finally {
      _isFetchingOnboarding = false;
    }
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    final token = data['access_token'] ?? data['token'];
    if (token == null || token.toString().isEmpty) {
      throw Exception('Missing token in response');
    }

    await _store!.setToken(token);

    if (data['tenant_id'] != null) {
      await _store!.setTenantId(data['tenant_id'].toString());
    }
    if (data['onboarding_process'] != null) {
      await _store!.setOnboardingProcess(data['onboarding_process'].toString());
    }

    if (data['user'] is Map) {
      final user = data['user'] as Map<String, dynamic>;
      if (user['name'] != null) await _store!.setUserName(user['name']);
      if (user['email'] != null) await _store!.setEmail(user['email']);
      if (user['picture'] != null) await _store!.setProfilePic(user['picture']);
    }

    await _store!.setLoggedIn(true);
    // Reset onboarding flags after new login/signup
    _onboardingCompleted = false;
    _isFetchingOnboarding = false;
  }

  String _safeError(http.Response res, String context) {
    try {
      final body = jsonDecode(res.body);
      return body['message']?.toString() ??
          body['error']?.toString() ??
          '$context (${res.statusCode})';
    } catch (_) {
      // Fallback for non-JSON or unexpected body
      if (res.statusCode >= 500) {
        return 'Server error (${res.statusCode}). Please try again later.';
      }
      return '$context (${res.statusCode})';
    }
  }
}

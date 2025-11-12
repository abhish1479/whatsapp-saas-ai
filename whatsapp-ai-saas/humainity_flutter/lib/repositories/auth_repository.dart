import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';

class AuthRepository {
  final _store = StoreUserData();

  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('Missing API_BASE_URL in .env');
    }
    return url;
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
    await _store.clear();
  }

  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    final token = data['token'];
    if (token == null || token.toString().isEmpty) {
      throw Exception('Missing token in response');
    }

    await _store.setToken(token);

    if (data['tenant_id'] != null) {
      await _store.setTenantId(data['tenant_id'].toString());
    }

    if (data['user'] is Map) {
      final user = data['user'] as Map<String, dynamic>;
      if (user['name'] != null) await _store.setUserName(user['name']);
      if (user['email'] != null) await _store.setEmail(user['email']);
      if (user['picture'] != null) await _store.setProfilePic(user['picture']);
    }

    await _store.setLoggedIn(true);
  }

  String _safeError(http.Response res, String context) {
    try {
      final body = jsonDecode(res.body);
      return body['error']?.toString() ?? '$context (${res.statusCode})';
    } catch (_) {
      return '$context (${res.statusCode})';
    }
  }
}

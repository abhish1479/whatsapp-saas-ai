import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:humainity_flutter/core/storage/store_user_data.dart';

final miniCrmRepositoryProvider = Provider<MiniCrmRepository>((ref) {
  final store = ref.watch(storeUserDataProvider);
  return MiniCrmRepository(store);
});

class MiniCrmRepository {
  final StoreUserData? _store;
  final String _erpBaseUrl = 'http://localhost:8090';

  MiniCrmRepository(this._store);

  Future<String> getMagicLink() async {
    if (_store == null) throw Exception("Storage not initialized");

    final keys = await _store!.getErpKeys();
    final apiKey = keys['key'];
    final apiSecret = keys['secret'];
    final email = await _store!.getEmail();

    if (apiKey == null || apiSecret == null) {
      throw Exception("ERP API Keys not found. Please log out and log in again.");
    }
    if (email == null) {
      throw Exception("User email not found.");
    }

    // UPDATED URL: Using the new session.get_magic_link endpoint
    final url = Uri.parse(
        '$_erpBaseUrl/api/method/mymobi_whatsapp_saas.mymobi_whatsapp_saas.session.get_magic_link?user_email=$email');

    try {
      // NOTE: Using GET here as typical for "get_" methods with query params,
      // but if your server requires POST, change to http.post(url, headers: ...)
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'token $apiKey:$apiSecret',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final link = body['message'] as String?;

        if (link != null && link.isNotEmpty) {
          // We return the Magic Link. The iframe will visit this,
          // which sets the cookie and 302 redirects to /app/home
          return link;
        } else {
          throw Exception("Empty magic link returned from server");
        }
      } else if (response.statusCode == 403) {
        throw Exception("Access Forbidden (403). Check your API Keys.");
      } else {
        throw Exception("Failed to fetch magic link: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection error: $e");
    }
  }
}
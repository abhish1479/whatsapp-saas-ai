import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ChatRepository {
  final http.Client _client;
  final String _baseUrl;

  ChatRepository(this._client)
      : _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<String> testAgent(String tenantId,String query) async {
    final uri = Uri.parse(
        '$_baseUrl/conversations/test_agent?query=${Uri.encodeComponent(query)}&tenant_id=$tenantId');

    try {
      final response = await _client.post(
        uri,
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['reply'] != null) {
          return body['reply'] as String;
        } else {
          throw Exception('Invalid response format: "reply" key missing.');
        }
      } else {
        throw Exception('Failed to get reply: ${response.body}');
      }
    } catch (e) {
      print('Error in testAgent: $e');
      rethrow;
    }
  }
}

// Provider for the HTTP client (if not already defined elsewhere)
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// Provider for the ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  return ChatRepository(client);
});
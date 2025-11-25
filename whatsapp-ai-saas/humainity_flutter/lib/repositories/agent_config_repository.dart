import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:humainity_flutter/models/agent_config_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // HINT: Added for kIsWeb and Uint8List
// --- CORRECTED IMPORT PATH AND USAGE ---
import 'package:humainity_flutter/core/storage/store_user_data.dart';

// --- 1. The Repository Provider (FINAL) ---
// This provider now watches the storeUserDataProvider
final agentConfigRepositoryProvider = Provider<AgentConfigRepository>((ref) {
  final storeUserData = ref.watch(storeUserDataProvider);
  // Ensure StoreUserData is initialized before accessing it
  if (storeUserData == null) {
    throw Exception('StoreUserData provider returned null.');
  }
  return AgentConfigRepository(storeUserData);
});

// --- 2. The Repository Class ---
class AgentConfigRepository {
  final StoreUserData storeUserData;
  final String _baseUrl;

  AgentConfigRepository(this.storeUserData)
      : _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

  // --- Helper for default empty configuration ---
  static AgentConfig _defaultEmptyConfig() {
    return AgentConfig(
      id: 0,
      tenantId: 0,
      agentName: 'Sarah',
      agentPersona:
          'Sarah specializes in identifying warm leads, qualifying prospects based on stated needs, and proactively booking follow-up demonstration calls.',
      greetingMessage: 'Hello! How can I assist you today?',
      preferredLanguages: ['en'],
      conversationTone: 'friendly',
      agentImage: null,
    );
  }

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await storeUserData.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetches the agent configuration from the API
  Future<AgentConfig> getAgentConfiguration() async {
    final tenantId = await storeUserData.getTenantId();
    final Map<String, String> headers = await _getHeaders();

    // Append the tenant_id as a query parameter
    final uri = Uri.parse(
        '$_baseUrl/agent-config/get_agent_configuration?tenant_id=$tenantId');

    try {
      final response = await http.get(uri, headers: headers);
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        // Successful response with data
        if (responseBody['data'] == null) {
          return _defaultEmptyConfig();
        }
        return AgentConfig.fromMap(responseBody['data']);
      } else if (response.statusCode != 200) {
        return _defaultEmptyConfig();
      } else {
        // Handle structured error response (e.g., actual server error, permission issue)
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        final errorDetails =
            responseBody['error']?['details']?.join(', ') ?? '';

        return _defaultEmptyConfig();
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  /// Saves the agent configuration to the API
  // HINT: FIX 3c - Updated signature to accept bytes and filename for web upload
  Future<String?> saveAgentConfiguration({
    required AgentConfig config,
    File? agentImageFile,
    Uint8List? agentImageBytes,
    String? agentImageFileName,
  }) async {
    final tenantId = await storeUserData.getTenantId();
    final token = await storeUserData.getToken();

    final uri = Uri.parse('$_baseUrl/agent-config/update_agent_configuration');

    try {
      // HINT: FIX 3 - Changed method from 'POST' to 'PUT' to fix 405 Method Not Allowed
      final request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // --- 1. Create JSON Payload (Matches AgentConfigPayload Pydantic Model) ---
      final configJsonPayload = json.encode({
        // Ensure tenant_id is an integer for the Pydantic model
        'tenant_id': int.parse(tenantId!),
        'agent_name': config.agentName,
        'agent_persona': config.agentPersona,
        'greeting_message': config.greetingMessage,
        // 'preferred_languages': config.preferredLanguages.join(','),
        'preferred_languages': config.preferredLanguages,
        'conversation_tone': config.conversationTone,
      });

      // Add the JSON payload as a single field named 'payload'
      request.fields['payload'] = configJsonPayload;

      // --- 2. Add Optional File (Cross-Platform) ---
      if (agentImageFile != null && !kIsWeb) {
        // Native platforms (File access via dart:io)
        request.files.add(
          await http.MultipartFile.fromPath(
            'agent_image', // MUST match Python argument name
            agentImageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else if (agentImageBytes != null && agentImageFileName != null) {
        // HINT: FIX 3c - Web platform (File access via bytes)
        request.files.add(
          http.MultipartFile.fromBytes(
            'agent_image',
            agentImageBytes,
            filename: agentImageFileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // --- 3. Send Request ---
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        // Return the new image URL from the saved data
        return responseBody['data']['agent_image'];
      } else {
        // Handle structured error response
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        final errorDetails =
            responseBody['error']?['details']?.join(', ') ?? '';

        throw Exception(
            'Failed to save configuration: $errorMessage. Details: $errorDetails');
      }
    } catch (e) {
      throw Exception('Failed to connect or save: $e');
    }
  }
}

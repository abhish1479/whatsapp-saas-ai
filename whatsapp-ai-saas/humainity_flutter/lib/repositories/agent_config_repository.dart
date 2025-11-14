import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:humainity_flutter/models/agent_config_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// --- CORRECTED IMPORT PATH AND USAGE ---
import 'package:humainity_flutter/core/storage/store_user_data.dart';

// --- 1. The Repository Provider (FINAL) ---
// This provider now watches the storeUserDataProvider
final agentConfigRepositoryProvider = Provider<AgentConfigRepository>((ref) {
  // Watch the correctly named storage service provider
  final storeUserData = ref.watch(storeUserDataProvider);

  // If SharedPreferences is still loading, storeUserData will be null.
  if (storeUserData == null) {
    return AgentConfigRepository(null, null);
  }

  // --- Get token and tenantId from StoreUserData ---
  final token = storeUserData.getToken();
  final tenantId = storeUserData.getTenantId(); // Fetch the tenant ID

  return AgentConfigRepository(token, tenantId);
});

// --- 2. The Repository Class ---
class AgentConfigRepository {
  final dynamic _token;
  final dynamic _tenantId;
  final String _baseUrl;

  AgentConfigRepository(this._token, this._tenantId)
      : _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  /// Fetches the agent configuration from the API
  Future<AgentConfig> getAgentConfiguration() async {
    if (_token == null) throw Exception('Not authenticated (no token)');
    if (_tenantId == null) {
      throw Exception('Tenant ID not found in local storage. Please log in.');
    }

    // Append the tenant_id as a query parameter
    final uri = Uri.parse(
        '$_baseUrl/agent-config/get_agent_configuration?tenant_id=$_tenantId');

    try {
      final response = await http.get(uri, headers: _headers);
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        // Parse data from the 'data' field of the APIResponse
        return AgentConfig.fromMap(responseBody['data']);
      } else {
        // Handle structured error response
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        final errorDetails =
            responseBody['error']?['details']?.join(', ') ?? '';

        throw Exception(
            'Failed to load agent configuration: $errorMessage. Details: $errorDetails');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }

  /// Saves the agent configuration to the API
  Future<String?> saveAgentConfiguration({
    required AgentConfig config,
    File? agentImageFile,
  }) async {
    if (_token == null) throw Exception('Not authenticated (no token)');
    if (_tenantId == null) {
      throw Exception('Tenant ID not found in local storage. Please log in.');
    }

    final uri = Uri.parse('$_baseUrl/agent-config/update_agent_configuration');

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $_token';

      // --- 1. Create JSON Payload (Matches AgentConfigPayload Pydantic Model) ---
      final configJsonPayload = json.encode({
        // Ensure tenant_id is an integer for the Pydantic model
        'tenant_id': int.parse(_tenantId!),
        'agent_name': config.agentName,
        'agent_persona': config.agentPersona,
        'greeting_message': config.greetingMessage,
        'preferred_languages': config.preferredLanguages.join(','),
        'conversation_tone': config.conversationTone,
      });

      // Add the JSON payload as a single field named 'payload'
      request.fields['payload'] = configJsonPayload;

      // --- 2. Add Optional File ---
      if (agentImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'agent_image', // MUST match Python argument name
            agentImageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // --- 3. Send Request ---
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
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

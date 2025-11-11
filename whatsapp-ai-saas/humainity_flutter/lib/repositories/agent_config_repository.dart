import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:humainity_flutter/models/agent_config_model.dart'; // Import new model
import 'package:path/path.dart' as p;

// --- PLACEHOLDER FOR API BASE URL ---
const String _baseUrl = 'http://127.0.0.1:8000'; // Mock base URL

// 1. Define the repository provider
final agentConfigRepositoryProvider = Provider((ref) {
  // You can read the auth token here if needed
  // final token = ref.watch(authTokenProvider);
  return AgentConfigRepository(baseUrl: _baseUrl, authToken: "YOUR_MOCK_TOKEN");
});

// 2. Define the repository class
class AgentConfigRepository {
  final String baseUrl;
  final String? authToken; // For auth
  final http.Client _client;

  AgentConfigRepository({
    required this.baseUrl,
    this.authToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  /// --- GET Agent Configuration ---
  Future<AgentConfig> getAgentConfiguration() async {
    final uri = Uri.parse('$baseUrl/agent-config/');
    try {
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return AgentConfig.fromJson(data);
      } else if (response.statusCode == 404) {
        // No config found, return defaults
        return AgentConfig.defaults();
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Network/HTTP error: $e');
      throw Exception('Failed to fetch agent configuration: $e');
    }
  }

  /// --- UPDATED: SAVE Agent Configuration ---
  Future<String?> saveAgentConfiguration({
    required AgentConfig config,
    File? agentImageFile, // Optional file
  }) async {
    final uri = Uri.parse('$baseUrl/agent-config/save');
    final request = http.MultipartRequest('POST', uri);

    // Set headers
    request.headers.addAll(_headers);

    // Add required text fields from the model
    request.fields['agent_name'] = config.agentName;
    request.fields['agent_persona'] = config.agentPersona;
    request.fields['greeting_message'] = config.greetingMessage;
    request.fields['preferred_languages'] = config.preferredLanguages.join(',');
    request.fields['conversation_tone'] = config.conversationTone;
    // request.fields['voice_model'] = config.voiceModel; // <-- REMOVED

    // File Upload Logic
    if (agentImageFile != null) {
      try {
        final filename = p.basename(agentImageFile.path);
        final filePart = await http.MultipartFile.fromPath(
          'agent_image', // Must match the FastAPI parameter name
          agentImageFile.path,
          filename: filename,
          contentType: MediaType(
              'image', p.extension(filename).toLowerCase().substring(1)),
        );
        request.files.add(filePart);
      } catch (e) {
        print('Error creating MultipartFile from path: $e');
        throw Exception('Error reading image file.');
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        // Return the new image URL if one was created
        return data['image_url'] as String?;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Network/HTTP error: $e');
      throw Exception('Failed to save agent configuration: $e');
    }
  }
}

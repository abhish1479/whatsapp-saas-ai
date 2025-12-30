import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/utils/api_client.dart';
import 'package:humainise_ai/core/providers/api_provider.dart';
import 'package:humainise_ai/core/storage/store_user_data.dart';
import 'package:humainise_ai/models/agent_config_model.dart';

final agentConfigRepositoryProvider = Provider<AgentConfigRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final store = ref.watch(storeUserDataProvider);
  return AgentConfigRepository(apiClient, store);
});

class AgentConfigRepository {
  final ApiClient _api;
  final StoreUserData? _store;

  AgentConfigRepository(this._api, this._store);

  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) throw Exception('Missing API_BASE_URL');
    return url;
  }

  /// 1. Get Agent by Tenant
  Future<AgentConfiguration?> getAgentByTenant(int tenantId) async {
    try {
      final data = await _api.get(
        '/agent-config/get_agent_configs_by_tenant?tenant_id=$tenantId',
        silent: true,
      );
      return AgentConfiguration.fromJson(data);
    } catch (e) {
      // 404 means no agent yet, return null so UI knows to show "Create" mode
      if (e.toString().contains('404')) return null;
      rethrow;
    }
  }

  /// 2. Create Agent
  Future<AgentConfiguration> createAgent(AgentConfiguration config) async {
    final data = await _api.post('/agent-config/create', body: config.toJson());
    return AgentConfiguration.fromJson(data);
  }

  /// 3. Update Agent
  Future<AgentConfiguration> updateAgent(AgentConfiguration config) async {
    final data = await _api.put('/agent-config/update', body: config.toJson());
    return AgentConfiguration.fromJson(data);
  }

  /// 4. Upload Image (Multipart)
  /// Returns the URL string of the uploaded image
  Future<String> uploadImage(File file) async {
    final uri = Uri.parse('$_baseUrl/catalog/image_upload');
    final token = await _store?.getToken();

    final request = http.MultipartRequest('POST', uri);

    // Add Headers
    request.headers.addAll({
      if (token != null) 'Authorization': 'Bearer $token',
      'accept': 'application/json',
    });

    // Add File
    // Note: API expects field name 'payload'
    final multipartFile =
        await http.MultipartFile.fromPath('payload', file.path);
    request.files.add(multipartFile);

    // Send
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final String imageUrl = jsonDecode(response.body)['image_url'];
      return imageUrl; // Simple cleanup if it's a raw string
    } else {
      throw Exception('Image upload failed: ${response.statusCode}');
    }
  }
}

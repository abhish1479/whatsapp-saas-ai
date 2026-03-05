import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import '../core/utils/api_client.dart';
import '../models/workflow.dart';
import '../core/storage/store_user_data.dart';

class WorkflowRepository {
  final ApiClient _apiClient;
  final StoreUserData _storeUserData;

 final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  WorkflowRepository(this._apiClient, this._storeUserData);

  Future<List<Workflow>> getWorkflows(String tenantId) async {
    final response =
        await _apiClient.get('/workflows/?tenant_id=$tenantId');

    if (response is List) {
      return response
          .map((json) => Workflow.fromJson(json))
          .toList();
    } else if (response is Map<String, dynamic>) {
      // If the API returns a single object, wrap it in a list
      return [Workflow.fromJson(response)];
    } else {
      // If the response is not a list or a map, return an empty list
      return [];
    }
  }

  Future<Workflow> createWorkflow(
      String tenantId,
      String name,
      String workflow) async {
    final response = await _apiClient.post(
      '/workflows/?tenant_id=$tenantId',
      body: {
        'name': name,
        'json': {"workflow": workflow},
      },
    );

    return Workflow.fromJson(response);
  }

  Future<Workflow> updateWorkflow(
      int workflowId,
      String name,
      String workflow,
      bool isDefault) async {
    final response = await _apiClient.put(
      '/workflows/$workflowId',
      body: {
        'name': name,
        'json': {"workflow": workflow},
        'is_default': isDefault,
      },
    );

    return Workflow.fromJson(response);
  }

  Future<void> deleteWorkflow(int workflowId) async {
    await _apiClient.delete('/workflows/$workflowId');
  }

  Future<String> optimizeWorkflow(
      String tenantId,
      String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final token = await _storeUserData.getToken();

    if (token == null) {
      throw Exception("Authentication token not found.");
    }

    final url = Uri.parse('$_baseUrl/workflows/workflow_optimizer?tenant_id=$tenantId&query=$encodedQuery');

    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to optimize workflow. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

}

  final workflowRepositoryProvider =
    Provider<WorkflowRepository>((ref) {
  final storeUserData = ref.watch(storeUserDataProvider);
  // We can't proceed if storeUserData is null, as it's essential for the repository.
  if (storeUserData == null) {
    throw Exception("StoreUserData is not available");
  }
  final apiClient = ApiClient(storeUserData);
  return WorkflowRepository(apiClient, storeUserData);
});
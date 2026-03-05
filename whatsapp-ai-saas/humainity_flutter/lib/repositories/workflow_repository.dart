import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/utils/api_client.dart';
import '../models/workflow.dart';
import '../core/storage/store_user_data.dart';

class WorkflowRepository {
  final ApiClient _apiClient;

  WorkflowRepository(this._apiClient);

  Future<List<Workflow>> getWorkflows(String tenantId) async {
    final response =
        await _apiClient.get('/workflows/?tenant_id=$tenantId');

    return (response as List)
        .map((json) => Workflow.fromJson(json))
        .toList();
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

    final response = await _apiClient.post(
      '/workflows/workflow_optimizer?tenant_id=$tenantId&query=$encodedQuery',
    );

     if (response is String) {
        return response;
     }

     if (response is Map<String, dynamic> && response.containsKey('workflow')) {
        return response['workflow'];
     }

     return response.toString();
  }

}

  final workflowRepositoryProvider =
    Provider<WorkflowRepository>((ref) {
  final storeUserData = ref.watch(storeUserDataProvider);
  final apiClient = ApiClient(storeUserData!);
  return WorkflowRepository(apiClient);
});
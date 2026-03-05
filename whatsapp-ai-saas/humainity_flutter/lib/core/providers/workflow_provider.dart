import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workflow.dart';
import '../../repositories/workflow_repository.dart';
import '../storage/store_user_data.dart';

class WorkflowState {
  final bool isLoading;
  final String? error;
  final List<Workflow> workflows;
  final Workflow? selectedWorkflow;

  WorkflowState({
    this.isLoading = false,
    this.error,
    this.workflows = const [],
    this.selectedWorkflow,
  });

  WorkflowState copyWith({
    bool? isLoading,
    String? error,
    List<Workflow>? workflows,
    Workflow? selectedWorkflow,
  }) {
    return WorkflowState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      workflows: workflows ?? this.workflows,
      selectedWorkflow: selectedWorkflow,
    );
  }
}

class WorkflowNotifier extends StateNotifier<WorkflowState> {
  final WorkflowRepository _repository;
  final StoreUserData _storeUserData;

  WorkflowNotifier(this._repository, this._storeUserData)
      : super(WorkflowState()) {
    loadWorkflows();
  }

  Future<void> loadWorkflows() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final tenantId = await _storeUserData.getTenantId();
      if (tenantId == null) throw Exception("Tenant not found");

      final workflows =
          await _repository.getWorkflows(tenantId.toString());

      state = state.copyWith(
        isLoading: false,
        workflows: workflows,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectWorkflow(Workflow? workflow) {
    state = state.copyWith(selectedWorkflow: workflow);
  }

  Future<bool> saveWorkflow(
      String name,
      String workflow,
      bool isDefault) async {
    // Preserve the selected workflow before the state is updated.
    final workflowToUpdate = state.selectedWorkflow;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final tenantId = await _storeUserData.getTenantId();
      if (tenantId == null) return false;

      // Use the preserved workflow to decide between create and update.
      if (workflowToUpdate == null) {
        await _repository.createWorkflow(
            tenantId.toString(), name, workflow);
      } else {
        await _repository.updateWorkflow(
            workflowToUpdate.id,
            name,
            workflow,
            isDefault);
      }

      await loadWorkflows();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> deleteWorkflow(int workflowId) async {
    try {
      await _repository.deleteWorkflow(workflowId);
      await loadWorkflows();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<String?> optimizeWorkflow(String query) async {
    try {
      final tenantId = await _storeUserData.getTenantId();
      if (tenantId == null) return null;

      return await _repository.optimizeWorkflow(
          tenantId.toString(), query);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final workflowProvider =
    StateNotifierProvider<WorkflowNotifier, WorkflowState>((ref) {
  final repository = ref.watch(workflowRepositoryProvider);
  final storeUserData = ref.watch(storeUserDataProvider);
  return WorkflowNotifier(repository, storeUserData!);
});
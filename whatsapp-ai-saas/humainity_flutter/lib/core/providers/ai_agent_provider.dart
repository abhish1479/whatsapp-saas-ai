import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/storage/store_user_data.dart';
import 'package:humainise_ai/models/agent_config_model.dart';
import 'package:humainise_ai/repositories/agent_config_repository.dart';

// --- State ---
class AgentState {
  final bool isLoading;
  final bool isSaving;
  final bool isEditing; // Controls Read-Only vs Edit mode
  final AgentConfiguration? agent;
  final File? localImageFile; // For preview before upload

  AgentState({
    this.isLoading = false,
    this.isSaving = false,
    this.isEditing = true, // Default to true (Create mode) until loaded
    this.agent,
    this.localImageFile,
  });

  AgentState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isEditing,
    AgentConfiguration? agent,
    File? localImageFile,
  }) {
    return AgentState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isEditing: isEditing ?? this.isEditing,
      agent: agent ?? this.agent,
      localImageFile: localImageFile ?? this.localImageFile,
    );
  }
}

// --- Notifier ---
class AgentConfigNotifier extends StateNotifier<AgentState> {
  final AgentConfigRepository _repo;
  final StoreUserData? _store;

  AgentConfigNotifier(this._repo, this._store) : super(AgentState());

  /// Load existing agent. If found, switch to View Mode (isEditing = false).
  Future<void> loadAgent() async {
    state = state.copyWith(isLoading: true);
    try {
      final tenantIdStr = await _store?.getTenantId();
      if (tenantIdStr == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final agent = await _repo.getAgentByTenant(int.parse(tenantIdStr));

      if (agent != null) {
        // Agent exists -> Show details, disable editing
        state =
            state.copyWith(isLoading: false, agent: agent, isEditing: false);
      } else {
        // No agent -> Create mode
        state = state.copyWith(isLoading: false, agent: null, isEditing: true);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // ApiClient handles global error toasts, so we just stop loading
    }
  }

  /// Enable editing mode
  void enableEditing() {
    state = state.copyWith(isEditing: true);
  }

  /// Cancel editing (revert to last saved state)
  void cancelEditing() {
    // Reload to reset fields
    loadAgent();
  }

  /// Stage a local image for preview
  void setLocalImage(File file) {
    state = state.copyWith(localImageFile: file);
  }

  /// Save (Create or Update)
  Future<void> saveAgent(AgentConfiguration inputConfig) async {
    state = state.copyWith(isSaving: true);
    try {
      String? imageUrl = inputConfig.agentImage;

      // 1. Upload Image if a new local file was picked
      if (state.localImageFile != null) {
        imageUrl = await _repo.uploadImage(state.localImageFile!);
      }

      // 2. Prepare Final Config
      final finalConfig = inputConfig.copyWith(agentImage: imageUrl);

      // 3. Create or Update
      if (finalConfig.id != null) {
        // Update
        final updated = await _repo.updateAgent(finalConfig);
        state = state.copyWith(
            isSaving: false,
            agent: updated,
            isEditing: false,
            localImageFile: null);
      } else {
        // Create
        final created = await _repo.createAgent(finalConfig);
        state = state.copyWith(
            isSaving: false,
            agent: created,
            isEditing: false,
            localImageFile: null);
      }
    } catch (e) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }
}

final agentConfigProvider =
    StateNotifierProvider<AgentConfigNotifier, AgentState>((ref) {
  final repo = ref.watch(agentConfigRepositoryProvider);
  final store = ref.watch(storeUserDataProvider);
  return AgentConfigNotifier(repo, store);
});

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/models/agent_config_model.dart';
import 'package:humainity_flutter/models/ai_agent.dart';
import 'package:humainity_flutter/repositories/agent_config_repository.dart';

/// State object for the AI Agent Screen
class AIAgentState {
  // The configuration data from the server
  final AsyncValue<AgentConfig> config;

  // Local file staged for upload
  final File? localImageFile;

  // Local preset ID (for UI selection state)
  final String? selectedPresetId;

  AIAgentState({
    this.config = const AsyncValue.loading(),
    this.localImageFile,
    this.selectedPresetId,
  });

  AIAgentState copyWith({
    AsyncValue<AgentConfig>? config,
    File? localImageFile,
    bool clearLocalImage = false,
    String? selectedPresetId,
  }) {
    return AIAgentState(
      config: config ?? this.config,
      localImageFile:
          clearLocalImage ? null : localImageFile ?? this.localImageFile,
      selectedPresetId: selectedPresetId ?? this.selectedPresetId,
    );
  }
}

/// The Provider (StateNotifier)
class AIAgentNotifier extends StateNotifier<AIAgentState> {
  final AgentConfigRepository _repository;

  AIAgentNotifier(this._repository) : super(AIAgentState()) {
    fetchAgentConfig();
  }

  /// Fetch initial config from the API
  Future<void> fetchAgentConfig() async {
    state = state.copyWith(config: const AsyncValue.loading());
    try {
      final config = await _repository.getAgentConfiguration();
      // Try to find a matching preset
      final matchingPresetId = _findMatchingPreset(config)?.id;

      state = state.copyWith(
        config: AsyncValue.data(config),
        selectedPresetId: matchingPresetId ??
            (config.agentImage == null ? 'agent-david' : null),
      );
    } catch (e, s) {
      state = state.copyWith(config: AsyncValue.error(e, s));
    }
  }

  /// Save the current configuration to the API
  Future<void> saveAgentConfig() async {
    // We only save if we have loaded data
    if (state.config.hasValue) {
      final configToSave = state.config.value!;

      // Set saving state (optional, but good UX)
      final oldState = state;
      state = state.copyWith(config: AsyncValue.loading());

      try {
        final newImageUrl = await _repository.saveAgentConfiguration(
          config: configToSave,
          agentImageFile: state.localImageFile,
        );

        // On success, update the state with the potentially new image URL
        // and clear the local file
        state = state.copyWith(
          config: AsyncValue.data(newImageUrl != null
              ? configToSave.copyWith(agentImage: newImageUrl)
              : configToSave),
          clearLocalImage: true,
        );
      } catch (e, s) {
        // On error, revert to old state and show error
        state = oldState.copyWith(config: AsyncValue.error(e, s));
      }
    }
  }

  /// Select a preset, updating the state
  void selectPreset(AiAgent agent) {
    if (!state.config.hasValue) return; // Guard

    state = state.copyWith(
      config: AsyncValue.data(
        state.config.value!.copyWith(
          agentName: agent.name,
          agentPersona: agent.role,
          agentImage: agent.imagePath,
        ),
      ),
      selectedPresetId: agent.id,
      clearLocalImage: true, // Clear local file when selecting preset
    );
  }

  /// Stage a local image file for upload
  void stageLocalImage(File imageFile, String localPath) {
    if (!state.config.hasValue) return; // Guard

    state = state.copyWith(
        localImageFile: imageFile,
        selectedPresetId: 'agent-david', // Switch to custom
        config: AsyncValue.data(state.config.value!.copyWith(
          agentName: "My Custom Agent",
          agentPersona: "Design your own AI persona from scratch.",
          // Note: We don't update agentImage URL until after saving
        )));
  }

  // --- Local state update methods ---
  void updateAgentName(String name) {
    if (state.config.hasValue) {
      state = state.copyWith(
          config:
              AsyncValue.data(state.config.value!.copyWith(agentName: name)));
    }
  }

  void updateAgentPersona(String persona) {
    if (state.config.hasValue) {
      state = state.copyWith(
          config: AsyncValue.data(
              state.config.value!.copyWith(agentPersona: persona)));
    }
  }

  void updateGreetingMessage(String message) {
    if (state.config.hasValue) {
      state = state.copyWith(
          config: AsyncValue.data(
              state.config.value!.copyWith(greetingMessage: message)));
    }
  }

  void updateLanguage(String langCode) {
    if (state.config.hasValue) {
      state = state.copyWith(
          config: AsyncValue.data(
              state.config.value!.copyWith(preferredLanguages: [langCode])));
    }
  }

  void updateTone(String tone) {
    if (state.config.hasValue) {
      state = state.copyWith(
          config: AsyncValue.data(
              state.config.value!.copyWith(conversationTone: tone)));
    }
  }

  /// Helper to find a preset that matches the loaded config
  AiAgent? _findMatchingPreset(AgentConfig config) {
    try {
      return presetAgents.firstWhere(
        (preset) =>
            preset.name == config.agentName &&
            preset.role == config.agentPersona &&
            preset.imagePath == config.agentImage,
      );
    } catch (e) {
      return null; // No match found
    }
  }
}

/// The main provider exposed to the UI
final aiAgentProvider =
    StateNotifierProvider<AIAgentNotifier, AIAgentState>((ref) {
  final repository = ref.watch(agentConfigRepositoryProvider);
  return AIAgentNotifier(repository);
});

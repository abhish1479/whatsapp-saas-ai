import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/models/agent_config_model.dart';
import 'package:humainity_flutter/models/ai_agent.dart';
import 'package:humainity_flutter/repositories/agent_config_repository.dart';

// --- 1. The State Object ---
// A simple class to hold all the data for the AI Agent Screen.
class AIAgentState {
  // The configuration data from the server, wrapped in AsyncValue
  // to handle loading/error states.
  final AsyncValue<AgentConfig> config;

  // A local file staged for upload (not yet on the server).
  final File? localImageFile;

  // The ID of the currently selected preset (for UI highlighting).
  final String? selectedPresetId;

  AIAgentState({
    this.config = const AsyncValue.loading(),
    this.localImageFile,
    this.selectedPresetId,
  });

  // Helper method to create a copy of the state
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

// --- 2. The Notifier (The "Brain") ---
// This class holds the logic. It calls the repository and manages the state.
class AIAgentNotifier extends StateNotifier<AIAgentState> {
  final AgentConfigRepository _repository;

  AIAgentNotifier(this._repository) : super(AIAgentState()) {
    // Fetch the data as soon as the provider is first read
    fetchAgentConfig();
  }

  /// Fetch initial config from the API
  Future<void> fetchAgentConfig() async {
    // Set state to loading
    state = state.copyWith(config: const AsyncValue.loading());
    try {
      // Call the repository
      final config = await _repository.getAgentConfiguration();

      // Try to find a matching preset
      final matchingPresetId = _findMatchingPreset(config)?.id;

      // Set state to data
      state = state.copyWith(
        config: AsyncValue.data(config),
        selectedPresetId: matchingPresetId ??
            (config.agentImage == null ? 'agent-david' : null),
        clearLocalImage: true, // Clear any stale local image
      );
    } catch (e, s) {
      // Set state to error
      state = state.copyWith(config: AsyncValue.error(e, s));
    }
  }

  /// Save the current configuration to the API
  Future<void> saveAgentConfig() async {
    // We can only save if we have data (not in a loading or error state)
    if (!state.config.hasValue) return;

    final configToSave = state.config.value!;

    // Set saving state (keeps old data but shows loading indicator)
    state = state.copyWith(config: AsyncValue.loading());

    try {
      // Call the repository, passing the config data and the local file
      final newImageUrl = await _repository.saveAgentConfiguration(
        config: configToSave,
        agentImageFile: state.localImageFile,
      );

      // On success, update the state with the new config (which may have
      // a new image URL) and clear the local file.
      state = state.copyWith(
        config: AsyncValue.data(newImageUrl != null
            ? configToSave.copyWith(agentImage: newImageUrl)
            : configToSave),
        clearLocalImage: true,
      );
    } catch (e, s) {
      // On error, revert to old data and show error
      state = state.copyWith(config: AsyncValue.error(e, s));
    }
  }

  /// Select a preset, updating the state locally
  void selectPreset(AiAgent agent) {
    if (!state.config.hasValue) return; // Guard

    // Update the config in our state with the preset's info
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
      config: AsyncValue.data(
        state.config.value!.copyWith(
          agentName: "My Custom Agent",
          agentPersona: "Design your own AI persona from scratch.",
          // Note: We don't update agentImage URL until after saving
        ),
      ),
    );
  }

  // --- Local state update methods ---
  // These methods update the state *synchronously* as the user types,
  // making the UI feel instantaneous.

  void updateAgentName(String name) {
    if (state.config.hasValue) {
      state = state.copyWith(
        config: AsyncValue.data(state.config.value!.copyWith(agentName: name)),
      );
    }
  }

  void updateAgentPersona(String persona) {
    if (state.config.hasValue) {
      state = state.copyWith(
        config: AsyncValue.data(
            state.config.value!.copyWith(agentPersona: persona)),
      );
    }
  }

  void updateGreetingMessage(String message) {
    if (state.config.hasValue) {
      state = state.copyWith(
        config: AsyncValue.data(
            state.config.value!.copyWith(greetingMessage: message)),
      );
    }
  }

  void updateLanguage(String langCode) {
    if (state.config.hasValue) {
      state = state.copyWith(
        config: AsyncValue.data(
            state.config.value!.copyWith(preferredLanguages: [langCode])),
      );
    }
  }

  void updateTone(String tone) {
    if (state.config.hasValue) {
      state = state.copyWith(
        config: AsyncValue.data(
            state.config.value!.copyWith(conversationTone: tone)),
      );
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

// --- 3. The Main Provider (Exposed to UI) ---
// This is the provider your AIAgentScreen will watch.
final aiAgentProvider =
    StateNotifierProvider<AIAgentNotifier, AIAgentState>((ref) {
  // It watches the repository provider...
  final repository = ref.watch(agentConfigRepositoryProvider);
  // ...and passes the repository instance to the Notifier.
  return AIAgentNotifier(repository);
});

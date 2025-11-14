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
      final matchingPreset = _findMatchingPreset(config);
      final matchingPresetId = matchingPreset?.id;

      // Start with the fetched config and matching ID
      AgentConfig finalConfig = config;
      String? finalSelectedPresetId = matchingPresetId;

      // --- MODIFIED LOGIC: Select first default preset if config is a blank slate ---
      // A "blank slate" is assumed if the agentName is empty AND no preset matched.
      if (matchingPreset == null &&
          finalConfig.agentName.isEmpty &&
          presetAgents.isNotEmpty) {
        final firstPreset = presetAgents.first;

        // 1. Update the CONFIG fields with the first preset's data (fills the form)
        finalConfig = config.copyWith(
          agentName: firstPreset.name,
          agentPersona: firstPreset.role,
          agentImage: firstPreset.imagePath,
        );

        // 2. Update the SELECTED PRESET ID for UI highlighting
        finalSelectedPresetId = firstPreset.id;
      } else if (matchingPreset == null && finalConfig.agentName.isNotEmpty) {
        // If a custom config was loaded (has data, but doesn't match a preset),
        // use the 'agent-david' ID as a proxy for the 'Custom Agent' selection.
        finalSelectedPresetId = 'agent-david';
      }

      // Set state to data
      state = state.copyWith(
        config: AsyncValue.data(finalConfig),
        selectedPresetId: finalSelectedPresetId,
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
    if (!state.config.hasValue) return;

    state = state.copyWith(
      localImageFile: imageFile,
      selectedPresetId: 'agent-david', // Custom
      config: AsyncValue.data(
        state.config.value!.copyWith(
          agentName: "",
          agentPersona: "Design your own AI persona from scratch.",
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

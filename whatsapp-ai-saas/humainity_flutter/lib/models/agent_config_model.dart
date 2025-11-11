import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:humainity_flutter/models/ai_agent.dart'; // Assuming presetAgents are here

/// Represents the agent configuration data fetched from and sent to the API.
class AgentConfig {
  final String agentName;
  final String? agentImage; // URL from API
  final String agentPersona;
  final String greetingMessage;
  // final String voiceModel; // <-- REMOVED
  final List<String> preferredLanguages; // Converted from "en,es"
  final String conversationTone;

  AgentConfig({
    required this.agentName,
    this.agentImage,
    required this.agentPersona,
    required this.greetingMessage,
    // required this.voiceModel, // <-- REMOVED
    required this.preferredLanguages,
    required this.conversationTone,
  });

  /// Creates a default config, optionally based on a preset.
  factory AgentConfig.defaults({AiAgent? preset}) {
    final agent = preset ?? presetAgents.first;
    return AgentConfig(
      agentName: agent.name,
      agentImage: agent.imagePath,
      agentPersona: agent.role,
      greetingMessage: 'Hello! How can I assist you today?',
      // voiceModel: 'standard_voice_1', // <-- REMOVED
      preferredLanguages: ['en'],
      conversationTone: 'friendly',
    );
  }

  /// Creates an instance from the API JSON response.
  factory AgentConfig.fromJson(Map<String, dynamic> json) {
    return AgentConfig(
      agentName: json['agent_name'] ?? '',
      agentImage: json['agent_image'],
      agentPersona: json['agent_persona'] ?? '',
      greetingMessage: json['greeting_message'] ?? '',
      // voiceModel: json['voice_model'] ?? 'standard_voice_1', // <-- REMOVED
      preferredLanguages: (json['preferred_languages'] as String? ?? 'en')
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      conversationTone: json['conversation_tone'] ?? 'friendly',
    );
  }

  /// Creates a copy of the instance with updated fields.
  AgentConfig copyWith({
    String? agentName,
    String? agentImage,
    String? agentPersona,
    String? greetingMessage,
    // String? voiceModel, // <-- REMOVED
    List<String>? preferredLanguages,
    String? conversationTone,
  }) {
    return AgentConfig(
      agentName: agentName ?? this.agentName,
      agentImage: agentImage ?? this.agentImage,
      agentPersona: agentPersona ?? this.agentPersona,
      greetingMessage: greetingMessage ?? this.greetingMessage,
      // voiceModel: voiceModel ?? this.voiceModel, // <-- REMOVED
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      conversationTone: conversationTone ?? this.conversationTone,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AgentConfig &&
        other.agentName == agentName &&
        other.agentImage == agentImage &&
        other.agentPersona == agentPersona &&
        other.greetingMessage == greetingMessage &&
        // other.voiceModel == voiceModel && // <-- REMOVED
        listEquals(other.preferredLanguages, preferredLanguages) &&
        other.conversationTone == conversationTone;
  }

  @override
  int get hashCode {
    return agentName.hashCode ^
        agentImage.hashCode ^
        agentPersona.hashCode ^
        greetingMessage.hashCode ^
        // voiceModel.hashCode ^ // <-- REMOVED
        preferredLanguages.hashCode ^
        conversationTone.hashCode;
  }
}

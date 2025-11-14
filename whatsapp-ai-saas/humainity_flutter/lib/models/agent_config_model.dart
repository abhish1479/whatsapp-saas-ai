import 'dart:convert';

// Helper function to convert list to comma-separated string
String _languagesFromList(List<String> languages) {
  return languages.join(',');
}

// Helper function to convert comma-separated string to list
List<String> _languagesToList(String languages) {
  if (languages.isEmpty) {
    return ['en']; // Default
  }
  return languages.split(',');
}

class AgentConfig {
  final int id;
  final int tenantId;
  final String agentName;
  final String? agentImage; // URL
  final String agentPersona;
  final String greetingMessage;
  final List<String> preferredLanguages; // ["en", "es"]
  final String conversationTone;

  AgentConfig({
    required this.id,
    required this.tenantId,
    required this.agentName,
    this.agentImage,
    required this.agentPersona,
    required this.greetingMessage,
    required this.preferredLanguages,
    required this.conversationTone,
  });

  // Create a copy with modified fields
  AgentConfig copyWith({
    int? id,
    int? tenantId,
    String? agentName,
    String? agentImage,
    String? agentPersona,
    String? greetingMessage,
    List<String>? preferredLanguages,
    String? conversationTone,
  }) {
    return AgentConfig(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      agentName: agentName ?? this.agentName,
      agentImage: agentImage ?? this.agentImage,
      agentPersona: agentPersona ?? this.agentPersona,
      greetingMessage: greetingMessage ?? this.greetingMessage,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      conversationTone: conversationTone ?? this.conversationTone,
    );
  }

  // From JSON (API to App)
  // Handles mapping snake_case from Python to camelCase in Dart
  factory AgentConfig.fromMap(Map<String, dynamic> map) {
    return AgentConfig(
      id: map['id']?.toInt() ?? 0,
      tenantId: map['tenant_id']?.toInt() ?? 0,
      agentName: map['agent_name'] ?? 'AI Agent',
      agentImage: map['agent_image'],
      agentPersona: map['agent_persona'] ?? '',
      greetingMessage: map['greeting_message'] ?? '',
      preferredLanguages: _languagesToList(map['preferred_languages'] ?? 'en'),
      conversationTone: map['conversation_tone'] ?? 'friendly',
    );
  }

  factory AgentConfig.fromJson(String source) =>
      AgentConfig.fromMap(json.decode(source));
}

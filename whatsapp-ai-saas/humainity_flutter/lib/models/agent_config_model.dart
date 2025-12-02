class AgentConfiguration {
  final int? id; // Null for new agents
  final int tenantId;
  final String agentName;
  final String? agentImage;
  final String? agentPersona;
  final String? greetingMessage;
  final String? voiceModel;
  final String? voiceAccent; // ✅ New Field
  final String preferredLanguages;
  final String conversationTone;

  AgentConfiguration({
    this.id,
    required this.tenantId,
    required this.agentName,
    this.agentImage,
    this.agentPersona,
    this.greetingMessage,
    this.voiceModel,
    this.voiceAccent,
    this.preferredLanguages = 'en',
    this.conversationTone = 'professional',
  });

  factory AgentConfiguration.fromJson(Map<String, dynamic> json) {
    return AgentConfiguration(
      id: json['id'],
      tenantId: json['tenant_id'],
      agentName: json['agent_name'] ?? '',
      agentImage: json['agent_image'],
      agentPersona: json['agent_persona'],
      greetingMessage: json['greeting_message'],
      voiceModel: json['voice_model'],
      voiceAccent: json['voice_accent'],
      preferredLanguages: json['preferred_languages'] ?? 'en',
      conversationTone: json['conversation_tone'] ?? 'professional',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'tenant_id': tenantId,
      'agent_name': agentName,
      'preferred_languages': preferredLanguages,
      'conversation_tone': conversationTone,
    };

    // Add optionals only if they have values or if we are updating
    if (id != null) data['id'] = id;
    if (agentImage != null) data['agent_image'] = agentImage;
    if (agentPersona != null) data['agent_persona'] = agentPersona;
    if (greetingMessage != null) data['greeting_message'] = greetingMessage;
    if (voiceModel != null) data['voice_model'] = voiceModel;
    if (voiceAccent != null) data['voice_accent'] = voiceAccent;

    return data;
  }

  // Helper to create a copy with modified fields
  AgentConfiguration copyWith({
    int? id,
    String? agentImage,
  }) {
    return AgentConfiguration(
      id: id ?? this.id,
      tenantId: this.tenantId,
      agentName: this.agentName,
      agentImage: agentImage ?? this.agentImage,
      agentPersona: this.agentPersona,
      greetingMessage: this.greetingMessage,
      voiceModel: this.voiceModel,
      voiceAccent: this.voiceAccent,
      preferredLanguages: this.preferredLanguages,
      conversationTone: this.conversationTone,
    );
  }
}
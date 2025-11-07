class Guardrail {
  final String id;
  final String guardrailType;
  final String description;
  final List<String> keywords;
  final String? redirectMessage;
  final bool isActive;

  Guardrail({
    required this.id,
    required this.guardrailType,
    required this.description,
    required this.keywords,
    this.redirectMessage,
    required this.isActive,
  });

  factory Guardrail.fromJson(Map<String, dynamic> json) {
    return Guardrail(
      id: json['id'],
      guardrailType: json['guardrail_type'],
      description: json['description'],
      keywords: List<String>.from(json['keywords'] ?? []),
      redirectMessage: json['redirect_message'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guardrail_type': guardrailType,
      'description': description,
      'keywords': keywords,
      'redirect_message': redirectMessage,
      'is_active': isActive,
    };
  }
}
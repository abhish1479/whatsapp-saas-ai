class MessageTemplate {
  final String id;
  final String name;
  final String type; // 'inbound' | 'outbound'
  final String messageText;
  final String? mediaUrl;
  final String? mediaType; // 'image' | 'video' | 'document' | 'audio'
  final String? buttonText;
  final String? buttonUrl;
  final bool isActive;
  final DateTime createdAt;

  MessageTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.messageText,
    this.mediaUrl,
    this.mediaType,
    this.buttonText,
    this.buttonUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory MessageTemplate.fromJson(Map<String, dynamic> json) {
    return MessageTemplate(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      messageText: json['message_text'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      buttonText: json['button_text'],
      buttonUrl: json['button_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
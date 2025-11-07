class Engagement {
  final String id;
  final String customerId;
  final String engagementType;
  final String? subject;
  final String content;
  final String? outcome;
  final String? createdBy;
  final DateTime createdAt;

  Engagement({
    required this.id,
    required this.customerId,
    required this.engagementType,
    this.subject,
    required this.content,
    this.outcome,
    this.createdBy,
    required this.createdAt,
  });

  factory Engagement.fromJson(Map<String, dynamic> json) {
    return Engagement(
      id: json['id'],
      customerId: json['customer_id'],
      engagementType: json['engagement_type'],
      subject: json['subject'],
      content: json['content'],
      outcome: json['outcome'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
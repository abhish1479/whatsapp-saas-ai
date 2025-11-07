class CustomerCampaign {
  final String id;
  final String customerId;
  final String campaignId;
  final String status;
  final String? responseStatus;
  final DateTime? respondedAt;
  final bool converted;
  final DateTime createdAt;
  final String? campaignName; // From the joined table

  CustomerCampaign({
    required this.id,
    required this.customerId,
    required this.campaignId,
    required this.status,
    this.responseStatus,
    this.respondedAt,
    required this.converted,
    required this.createdAt,
    this.campaignName,
  });

  factory CustomerCampaign.fromJson(Map<String, dynamic> json) {
    String? name;
    if (json['campaigns'] != null && json['campaigns'] is Map) {
      name = json['campaigns']['name'];
    }

    return CustomerCampaign(
      id: json['id'],
      customerId: json['customer_id'],
      campaignId: json['campaign_id'],
      status: json['status'] ?? 'sent',
      responseStatus: json['response_status'],
      respondedAt: json['responded_at'] != null ? DateTime.parse(json['responded_at']) : null,
      converted: json['converted'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      campaignName: name,
    );
  }
}
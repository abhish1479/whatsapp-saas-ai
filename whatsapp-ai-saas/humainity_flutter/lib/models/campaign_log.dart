// This file was created to resolve build errors.
// It defines the 'CampaignLog' model based on fields
// accessed in other parts of the app.

class CampaignLog {
  final String id;
  final String campaignId;
  final String status;
  final String message; // FIX: Added 'message'
  final String? contactIdentifier; // FIX: Added 'contactIdentifier'
  final DateTime createdAt;

  CampaignLog({
    required this.id,
    required this.campaignId,
    required this.status,
    required this.message,
    this.contactIdentifier,
    required this.createdAt,
  });

  factory CampaignLog.fromJson(Map<String, dynamic> json) {
    return CampaignLog(
      id: json['id'] as String,
      campaignId: json['campaign_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      contactIdentifier: json['contact_identifier'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
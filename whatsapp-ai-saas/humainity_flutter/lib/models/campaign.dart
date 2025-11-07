// This file was created to resolve build errors.
// It defines the 'Campaign' model based on fields
// accessed in other parts of the app.

class Campaign {
  final String id;
  final String name;
  final String? description; // FIX: Added 'description'
  final String status;
  final String channel;
  final int totalContacts;
  final int contactsReached;
  final int successfulDeliveries;
  final int failedDeliveries;

  // FIX: Added 'engagementRate'
  // This is a calculated field, so we add a getter.
  // Assumes successfulDeliveries is part of contactsReached.
  double get engagementRate {
    if (contactsReached == 0) {
      return 0.0;
    }
    // Example logic: (successful / reached) * 100
    // Adjust logic as needed.
    return (successfulDeliveries / contactsReached) * 100.0;
  }

  Campaign({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.channel,
    required this.totalContacts,
    required this.contactsReached,
    required this.successfulDeliveries,
    required this.failedDeliveries,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      channel: json['channel'] as String,
      totalContacts: (json['total_contacts'] as num?)?.toInt() ?? 0,
      contactsReached: (json['contacts_reached'] as num?)?.toInt() ?? 0,
      successfulDeliveries: (json['successful_deliveries'] as num?)?.toInt() ?? 0,
      failedDeliveries: (json['failed_deliveries'] as num?)?.toInt() ?? 0,
    );
  }
}
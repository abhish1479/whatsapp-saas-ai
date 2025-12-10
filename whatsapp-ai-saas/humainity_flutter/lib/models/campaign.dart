import 'package:flutter/material.dart';

class Campaign {
  final int id;
  final String name;
  final String? description; // Maps to 'default_pitch' from server
  final String status;
  final String channel;
  final DateTime createdAt;

  // Stats from server response
  final int totalLeads;
  final int newLeads;
  final int sent;
  final int failed;
  final int success;

  // Extra detail fields
  final String? templateName;

  const Campaign({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.channel,
    required this.createdAt,
    required this.totalLeads,
    required this.newLeads,
    required this.sent,
    required this.failed,
    required this.success,
    this.templateName,
  });

  // Calculated getter for UI consistency
  double get engagementRate {
    if (sent == 0) return 0.0;
    return (success / sent) * 100.0;
  }

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['default_pitch'] as String?,
      status: json['status'] as String,
      channel: json['channel'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalLeads: (json['total_leads'] as num?)?.toInt() ?? 0,
      newLeads: (json['new'] as num?)?.toInt() ?? 0,
      sent: (json['sent'] as num?)?.toInt() ?? 0,
      failed: (json['failed'] as num?)?.toInt() ?? 0,
      success: (json['success'] as num?)?.toInt() ?? 0,
      templateName: json['template_name'] as String?,
    );
  }
}
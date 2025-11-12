import 'package:flutter/foundation.dart';

// Enum for Template Status, based on your server
enum TemplateStatus {
  DRAFT("Draft"),
  SUBMITTED("Submitted"),
  ACTIVATED("Activated"),
  DEACTIVATED("Deactivated"),
  UNKNOWN("Unknown"); // Fallback

  const TemplateStatus(this.value);
  final String value;

  static TemplateStatus fromString(String? status) {
    // Case-insensitive matching for robustness
    switch (status?.toLowerCase()) {
      case 'draft':
        return DRAFT;
      case 'submitted':
        return SUBMITTED;
      case 'activated':
        return ACTIVATED;
      case 'deactivated':
        return DEACTIVATED;
      default:
        return UNKNOWN;
    }
  }

  String toJson() => value; // Serialize to "Draft", "Submitted", etc.
  String get displayName => value; // For UI display
}

// Enum for Template Type, based on your server
enum TemplateType {
  INBOUND("Inbound"),
  OUTBOUND("Outbound"),
  UNKNOWN("Unknown"); // Fallback

  const TemplateType(this.value);
  final String value;

  static TemplateType fromString(String? type) {
    // Case-insensitive matching for robustness
    switch (type?.toLowerCase()) {
      case 'inbound':
        return INBOUND;
      case 'outbound':
        return OUTBOUND;
      default:
        return UNKNOWN;
    }
  }

  String toJson() => value; // Serialize to "Inbound", "Outbound"
  String get displayName => value; // For UI display
}

class Template {
  final int id;
  final int tenantId;
  final String name;
  final String language;
  final String category;
  final String body;
  final TemplateStatus status;
  final TemplateType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  Template({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.language,
    required this.category,
    required this.body,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to parse from JSON
  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'],
      tenantId: json['tenant_id'],
      name: json['name'],
      language: json['language'] ?? 'en',
      category: json['category'] ?? 'MARKETING',
      body: json['body'],
      status: TemplateStatus.fromString(json['status']),
      type: TemplateType.fromString(json['type']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Helper method to create a map for API requests
  // This is used for both create and update
  Map<String, dynamic> toApiJson({int? tenantId}) {
    // FIX: Explicitly type map as <String, dynamic> to prevent inference error
    final Map<String, dynamic> map = {
      'name': name,
      'language': language,
      'category': category,
      'body': body,
      'status': status.toJson(),
      'type': type.toJson(),
    };
    if (tenantId != null) {
      map['tenant_id'] = tenantId;
    }
    return map;
  }

  // CopyWith for easily creating modified instances
  Template copyWith({
    int? id,
    int? tenantId,
    String? name,
    String? language,
    String? category,
    String? body,
    TemplateStatus? status,
    TemplateType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Template(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      language: language ?? this.language,
      category: category ?? this.category,
      body: body ?? this.body,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Template &&
        other.id == id &&
        other.tenantId == tenantId &&
        other.name == name &&
        other.language == language &&
        other.category == category &&
        other.body == body &&
        other.status == status &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    tenantId.hashCode ^
    name.hashCode ^
    language.hashCode ^
    category.hashCode ^
    body.hashCode ^
    status.hashCode ^
    type.hashCode;
  }
}
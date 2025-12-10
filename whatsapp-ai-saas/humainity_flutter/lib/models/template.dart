import 'package:flutter/foundation.dart';

// Enum for Template Status
enum TemplateStatus {
  DRAFT("Draft"),
  SUBMITTED("Submitted"),
  ACTIVATED("Activated"),
  DEACTIVATED("Deactivated"),
  UNKNOWN("Unknown");

  const TemplateStatus(this.value);
  final String value;

  static TemplateStatus fromString(String? status) {
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

  String toJson() => value;
  String get displayName => value;
}

// Enum for Template Type (Inbound/Outbound)
enum TemplateType {
  INBOUND("Inbound"),
  OUTBOUND("Outbound"),
  UNKNOWN("Unknown");

  const TemplateType(this.value);
  final String value;

  static TemplateType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'inbound':
        return INBOUND;
      case 'outbound':
        return OUTBOUND;
      default:
        return UNKNOWN;
    }
  }

  String toJson() => value;
  String get displayName => value;
}

// NEW: Enum for Media Type
enum MediaType {
  TEXT("text"),
  VIDEO("video"),
  DOCUMENT("document"),
  IMAGE("image"), // Added for completeness, though you asked for text/video/document
  UNKNOWN("unknown");

  const MediaType(this.value);
  final String value;

  static MediaType fromString(String? type) {
    switch (type?.toLowerCase()) {
      case 'text':
        return TEXT;
      case 'video':
        return VIDEO;
      case 'document':
        return DOCUMENT;
      case 'image':
        return IMAGE;
      default:
        return TEXT; // Default to text
    }
  }

  String toJson() => value;
  String get displayName => value[0].toUpperCase() + value.substring(1);
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

  // NEW FIELDS
  final String? mediaLink;
  final MediaType mediaType;

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
    this.mediaLink,
    this.mediaType = MediaType.TEXT,
    required this.createdAt,
    required this.updatedAt,
  });

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
      // Parse new fields
      mediaLink: json['media_link'],
      mediaType: MediaType.fromString(json['media_type'] ?? 'text'),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toApiJson({int? tenantId}) {
    final Map<String, dynamic> map = {
      'name': name,
      'language': language,
      'category': category,
      'body': body,
      'status': status.toJson(),
      'type': type.toJson(),
      // Serialize new fields
      'media_link': mediaLink,
      'media_type': mediaType.toJson(),
    };
    if (tenantId != null) {
      map['tenant_id'] = tenantId;
    }
    return map;
  }

  Template copyWith({
    int? id,
    int? tenantId,
    String? name,
    String? language,
    String? category,
    String? body,
    TemplateStatus? status,
    TemplateType? type,
    String? mediaLink,
    MediaType? mediaType,
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
      mediaLink: mediaLink ?? this.mediaLink,
      mediaType: mediaType ?? this.mediaType,
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
        other.type == type &&
        other.mediaLink == mediaLink &&
        other.mediaType == mediaType;
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
    type.hashCode ^
    mediaLink.hashCode ^
    mediaType.hashCode;
  }
}
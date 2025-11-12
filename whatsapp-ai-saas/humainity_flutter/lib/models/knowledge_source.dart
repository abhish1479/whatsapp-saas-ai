import 'package:flutter/foundation.dart' show listEquals;

class KnowledgeSource {
  final int id;
  final String name;
  final String sourceType; // "FILE" or "URL"
  final String sourceUri;
  final int tenantId;
  final String processingStatus; // "PENDING", "TRAINED", "FAILED"
  final List<String> tags;
  final int? sizeBytes;
  final String? processingError;
  final String? summary;

  KnowledgeSource({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.sourceUri,
    required this.tenantId,
    required this.processingStatus,
    required this.tags,
    this.sizeBytes,
    this.processingError,
    this.summary
  });

  factory KnowledgeSource.fromJson(Map<String, dynamic> json) {
    return KnowledgeSource(
      id: json['id'],
      name: json['name'],
      sourceType: json['source_type'],
      sourceUri: json['source_uri'],
      tenantId: json['tenant_id'],
      processingStatus: json['processing_status'],
      // Ensure tags is always a List<String>
      tags: List<String>.from(json['tags']?.map((e) => e.toString()) ?? []),
      sizeBytes: json['size_bytes'],
      processingError: json['processing_error'],
      summary: json['summary'],
    );
  }

  // Helper to format file size
  String get formattedSize {
    if (sizeBytes == null) return 'N/A';
    if (sizeBytes! < 1024) return '$sizeBytes B';
    if (sizeBytes! < 1024 * 1024) return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Equatable for easy state updates
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is KnowledgeSource &&
        other.id == id &&
        other.name == name &&
        other.sourceType == sourceType &&
        other.sourceUri == sourceUri &&
        other.tenantId == tenantId &&
        other.processingStatus == processingStatus &&
        listEquals(other.tags, tags) &&
        other.sizeBytes == sizeBytes &&
        other.processingError == processingError &&
        other.summary == summary;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    sourceType.hashCode ^
    sourceUri.hashCode ^
    tenantId.hashCode ^
    processingStatus.hashCode ^
    tags.hashCode ^
    sizeBytes.hashCode ^
    processingError.hashCode;
    summary.hashCode;
  }
}
import 'dart:convert';

class Workflow {
  final int id;
  final String tenantId;
  final String name;
  final String workflow;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workflow({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.workflow,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Workflow.fromJson(Map<String, dynamic> json) {
    dynamic body = json['json_body'] ?? json['json'];
    String workflowValue = "";

    if (body is String) {
      try {
        // Body might be a JSON string, so we decode it.
        final decodedBody = jsonDecode(body);
        if (decodedBody is Map<String, dynamic>) {
          workflowValue = decodedBody['workflow'] ?? '';
        } else {
          // If decoded body is not a map, or it is just a string
          workflowValue = decodedBody.toString();
        }
      } catch (e) {
        // If it's not a valid JSON string, treat it as a plain string.
        workflowValue = body;
      }
    } else if (body is Map<String, dynamic>) {
      workflowValue = body['workflow'] ?? '';
    }

    // Clean up the workflow string
    if (workflowValue.startsWith('"') && workflowValue.endsWith('"')) {
      workflowValue = workflowValue.substring(1, workflowValue.length - 1);
    }
    workflowValue = workflowValue.replaceAll('\\n', '\n');

    return Workflow(
      id: json['id'] as int,
      tenantId: json['tenant_id']
          .toString(), // Handle both int and str from backend
      name: json['name'] as String,
      workflow: workflowValue,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'json': {'workflow': workflow},
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
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
    return Workflow(
      id: json['id'] as int,
      tenantId: json['tenant_id'].toString(), // Handle both int and str from backend
      name: json['name'] as String,
      workflow: (json['json_body'] ?? json['json'])?['workflow'] ?? "",
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
       "workflow": workflow,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
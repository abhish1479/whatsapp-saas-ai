class Customer {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? company;
  final String source;
  final String status;
  final String? assignedTo;
  final List<String> tags;
  final String? notes;
  final int totalInteractions;
  final DateTime? lastContactAt;
  final DateTime createdAt;
  final int? campaignCount;
  final double? totalSpent;
  final double? lifetimeValue;

  Customer({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.company,
    required this.source,
    required this.status,
    this.assignedTo,
    required this.tags,
    this.notes,
    required this.totalInteractions,
    this.lastContactAt,
    required this.createdAt,
    this.campaignCount,
    this.totalSpent,
    this.lifetimeValue,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      company: json['company'],
      source: json['source'],
      status: json['status'] ?? 'new',
      assignedTo: json['assigned_to'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      notes: json['notes'],
      totalInteractions: (json['total_interactions'] as num?)?.toInt() ?? 0,
      lastContactAt: json['last_contact_at'] != null
          ? DateTime.parse(json['last_contact_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      campaignCount: (json['campaign_count'] as num?)?.toInt(),
      totalSpent: (json['total_spent'] as num?)?.toDouble(),
      lifetimeValue: (json['lifetime_value'] as num?)?.toDouble(),
    );
  }

  // FIX: Added copyWith to allow for immutable updates
  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? source,
    String? status,
    String? assignedTo,
    List<String>? tags,
    String? notes,
    int? totalInteractions,
    DateTime? lastContactAt,
    DateTime? createdAt,
    int? campaignCount,
    double? totalSpent,
    double? lifetimeValue,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      source: source ?? this.source,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      totalInteractions: totalInteractions ?? this.totalInteractions,
      lastContactAt: lastContactAt ?? this.lastContactAt,
      createdAt: createdAt ?? this.createdAt,
      campaignCount: campaignCount ?? this.campaignCount,
      totalSpent: totalSpent ?? this.totalSpent,
      lifetimeValue: lifetimeValue ?? this.lifetimeValue,
    );
  }
}
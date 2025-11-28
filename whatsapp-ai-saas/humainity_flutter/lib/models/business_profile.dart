import 'dart:convert';

class BusinessProfile {
  final int id;
  final int tenantId;
  final String businessName;
  final String businessWhatsapp;
  final String? personalNumber;
  final String language;
  final String? businessType;
  final String? description;
  final bool isActive;

  BusinessProfile({
    required this.id,
    required this.tenantId,
    required this.businessName,
    required this.businessWhatsapp,
    this.personalNumber,
    required this.language,
    this.businessType,
    this.description,
    required this.isActive,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['id'],
      tenantId: json['tenant_id'],
      businessName: json['business_name'],
      businessWhatsapp: json['business_whatsapp'],
      personalNumber: json['personal_number'],
      language: json['language'] ?? 'en',
      businessType: json['business_type'],
      description: json['description'],
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'business_name': businessName,
      'business_whatsapp': businessWhatsapp,
      'personal_number': personalNumber,
      'language': language,
      'business_type': businessType,
      'description': description,
      'is_active': isActive,
    };
  }
}

class BusinessProfileCreate {
  final int tenantId;
  final String businessName;
  final String businessWhatsapp;
  final String? personalNumber;
  final String language;
  final String? businessType;
  final String? description;

  BusinessProfileCreate({
    required this.tenantId,
    required this.businessName,
    required this.businessWhatsapp,
    this.personalNumber,
    this.language = 'en',
    this.businessType,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'business_name': businessName,
      'business_whatsapp': businessWhatsapp,
      'personal_number': personalNumber,
      'language': language,
      'business_type': businessType,
      'description': description,
    };
  }
}

class BusinessProfileUpdate {
  final int id;
  final String? businessName;
  final String? businessWhatsapp;
  final String? personalNumber;
  final String? language;
  final String? businessType;
  final String? description;

  BusinessProfileUpdate({
    required this.id,
    this.businessName,
    this.businessWhatsapp,
    this.personalNumber,
    this.language,
    this.businessType,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id};
    if (businessName != null) data['business_name'] = businessName;
    if (businessWhatsapp != null) data['business_whatsapp'] = businessWhatsapp;
    if (personalNumber != null) data['personal_number'] = personalNumber;
    if (language != null) data['language'] = language;
    if (businessType != null) data['business_type'] = businessType;
    if (description != null) data['description'] = description;
    return data;
  }
}
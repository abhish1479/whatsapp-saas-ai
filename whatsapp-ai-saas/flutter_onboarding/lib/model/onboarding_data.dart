// lib/models/onboarding_data.dart
class OnboardingData {
  final int tenantId;
  final String onboardingProcess;
  final bool hasBusinessProfile;
  final bool hasBusinessType;
  final bool hasItems;
  final bool hasWebIngest;
  final bool hasWorkflow;
  final bool hasPayment;
  final int itemCount;
  final bool hasProfileActivate;
  final String businessName;
  final String businessWhatsapp;     // CHANGED
  final String personalNumber;
  final String businessType;
  final String businessDescription;
  final String customBusinessType;
  final String businessCategory;
  final List<Item> items;
  final WebIngest? webIngest;
  final Workflow? workflow;
  final Payment? payment;
  final AgentConfiguration? agentConfiguration;
  final Tenant? tenant;

  OnboardingData({
    required this.tenantId,
    required this.onboardingProcess,
    required this.hasBusinessProfile,
    required this.hasBusinessType,
    required this.hasItems,
    required this.hasWebIngest,
    required this.hasWorkflow,
    required this.hasPayment,
    required this.itemCount,
    required this.hasProfileActivate,
    required this.businessName,
    required this.businessWhatsapp,
    required this.personalNumber,
    required this.businessType,
    required this.businessDescription,
    required this.customBusinessType,
    required this.businessCategory,
    required this.items,
    this.webIngest,
    this.workflow,
    this.payment,
    this.agentConfiguration,
    this.tenant
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List?;
    List<Item> itemsList = [];
    if (itemsJson != null) {
      itemsList = itemsJson.map((i) => Item.fromJson(i as Map<String, dynamic>)).toList();
    }

    return OnboardingData(
      tenantId: json['tenant_id'] ?? -1,
      onboardingProcess: json['onboarding_process'] ?? 'Pending',
      hasBusinessProfile: json['has_business_profile'] ?? false,
      hasBusinessType: json['has_business_type'] ?? false,
      hasItems: json['has_items'] ?? false,
      hasWebIngest: json['has_web_ingest'] ?? false,
      hasWorkflow: json['has_workflow'] ?? false,
      hasPayment: json['has_payment'] ?? false,
      itemCount: json['item_count'] is int ? json['item_count'] : 0,
      hasProfileActivate: json['has_profile_activate'] ?? false,
      businessName: json['business_name'] ?? '',
      businessWhatsapp: json['business_whatsapp'] ?? '',     // CHANGED
      personalNumber: json['personal_number'] ?? '',         // NEW
      businessType: json['business_type'] ?? '',
      businessDescription: json['business_description'] ?? '',
      customBusinessType: json['custom_business_type'] ?? '',
      businessCategory: json['business_category'] ?? '',
      items: itemsList,
      webIngest: json['web_ingest'] != null
          ? WebIngest.fromJson(json['web_ingest'] as Map<String, dynamic>)
          : null,
      workflow: json['workflow'] != null
          ? Workflow.fromJson(json['workflow'] as Map<String, dynamic>)
          : null,
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      agentConfiguration: json['agent_configuration'] != null
          ? AgentConfiguration.fromJson(json['agent_configuration'] as Map<String, dynamic>)
          : null,
      tenant: json['tenant'] != null
          ? Tenant.fromJson(json['tenant'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Item {
  final int id;
  final String name;
  final double price;
  final String description;
  final String? imageUrl;
  final String createdAt;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      description: json['description'] ?? '',
      imageUrl: json['image_url'] is String ? json['image_url'] : null,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class WebIngest {
  final String id;
  final String url;
  final String status;
  final String createdAt;

  WebIngest({
    required this.id,
    required this.url,
    required this.status,
    required this.createdAt,
  });

  factory WebIngest.fromJson(Map<String, dynamic> json) {
    return WebIngest(
      id: json['id'] ?? '',
      url: (json['url'] is String) ? (json['url'] as String).trim() : '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class Workflow {
  final String template;
  final bool askName;
  final bool askLocation;
  final bool offerPayment;
  final String upiId;
  final String qrImageUrl;
  final String updatedAt;

  Workflow({
    required this.template,
    required this.askName,
    required this.askLocation,
    required this.offerPayment,
    required this.upiId,
    required this.qrImageUrl,
    required this.updatedAt,
  });

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      template: json['template'] ?? '',
      askName: json['ask_name'] ?? false,
      askLocation: json['ask_location'] ?? false,
      offerPayment: json['offer_payment'] ?? false,
      upiId: json['upi_id'] ?? '',
      qrImageUrl: json['qr_image_url'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Payment {
  final String upiId;
  final String bankDetails;
  final String checkoutLink;
  final String updatedAt;

  Payment({
    required this.upiId,
    required this.bankDetails,
    required this.checkoutLink,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      upiId: json['upi_id'] ?? '',
      bankDetails: json['bank_details'] ?? '',
      checkoutLink: json['checkout_link'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class AgentConfiguration {
  final String agentName;
  final String agentImage;
  final String status;
  final String preferredLanguages;
  final String conversationTone;
  final bool incomingVoiceMessageEnabled;
  final bool outgoingVoiceMessageEnabled;
  final bool incomingMediaMessageEnabled;
  final bool outgoingMediaMessageEnabled;
  final bool imageAnalyzerEnabled;
  final String createdAt;
  final String updatedAt;

  AgentConfiguration({
    required this.agentName,
    required this.agentImage,
    required this.status,
    required this.preferredLanguages,
    required this.conversationTone,
    required this.incomingVoiceMessageEnabled,
    required this.outgoingVoiceMessageEnabled,
    required this.incomingMediaMessageEnabled,
    required this.outgoingMediaMessageEnabled,
    required this.imageAnalyzerEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgentConfiguration.fromJson(Map<String, dynamic> json) {
    return AgentConfiguration(
      agentName: json['agent_name'] ?? '',
      agentImage: (json['agent_image'] is String)
          ? (json['agent_image'] as String).trim()
          : '',
      status: json['status'] ?? '',
      preferredLanguages: json['preferred_languages'] ?? 'English',
      conversationTone: json['conversation_tone'] ?? 'Friendly',
      incomingVoiceMessageEnabled: json['incoming_voice_message_enabled'] ??
          false,
      outgoingVoiceMessageEnabled: json['outgoing_voice_message_enabled'] ??
          false,
      incomingMediaMessageEnabled: json['incoming_media_message_enabled'] ??
          false,
      outgoingMediaMessageEnabled: json['outgoing_media_message_enabled'] ??
          false,
      imageAnalyzerEnabled: json['image_analyzer_enabled'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Tenant {
    final int id;
    final String name;
    final String plan;
    final bool ragEnabled;
    final String? ragUpdatedAt;
    final String createdAt;
    final String updatedAt;

      Tenant({
        required this.id,
        required this.name,
        required this.plan,
        required this.ragEnabled,
        this.ragUpdatedAt,
        required this.createdAt,
        required this.updatedAt,
        });

      factory Tenant.fromJson(Map<String, dynamic> json) {
        return Tenant(
          id: json['id'] as int? ?? 0,
          name: json['name'] ?? '',
          plan: json['plan'] ?? '',
          ragEnabled: json['rag_enabled'] ?? false,
          ragUpdatedAt: json['rag_updated_at'] is String ? json['rag_updated_at'] : null,
          createdAt: json['created_at'] is String ? json['created_at'] : '',
          updatedAt: json['updated_at'] is String ? json['updated_at'] : '',
          );
      }
}
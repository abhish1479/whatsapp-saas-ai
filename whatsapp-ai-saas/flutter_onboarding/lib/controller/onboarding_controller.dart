// lib/controllers/onboarding_controller.dart
import 'dart:developer' as AppLogger;

import 'package:get/get.dart';
import '../api/api.dart';
import '../model/onboarding_data.dart';

class OnboardingController extends GetxController {
  final Api _api;

  OnboardingController(this._api);

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  OnboardingData? _data;

  OnboardingData? get data => _data;

  Future<void> fetchOnboardingData(int tenantId) async {
    // if (_data != null) return;

    isLoading(true);
    errorMessage('');

    try {
      // ✅ Api क्लास का उपयोग — कोई hardcode नहीं
      final response = await _api.postForm('/onboarding/get_review', {
        'tenant_id': tenantId.toString(),
      });

      // ✅ Null-safe parsing
      if (response.containsKey('tenant_id')) {
        _data = OnboardingData.fromJson(response);
      } else {
        errorMessage.value = 'Invalid response format';
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
    } finally {
      isLoading(false);
      update();
    }
  }

  Future<void> refreshData(int tenantId) async {
    _data = null;
    await fetchOnboardingData(tenantId);
  }

  Future<Map<String, dynamic>> submitBusinessType({
    required int tenantId,
    required String businessType,
    String? description,
    String? customBusinessType,
    String? businessCategory,
  }) async {
    try {
      final response = await _api.postJson('/onboarding/type', {
        'tenant_id': tenantId,
        'business_type': businessType,
        'description': description ?? '',
        'custom_business_type': customBusinessType ?? '',
        'business_category': businessCategory ?? '',
      });
      return response;
    } catch (e) {
      AppLogger.log('submitBusinessType error: $e');
      return {'status': 'error', 'detail': e.toString()};
    }
  }

  /// --- Submit Workflow Setup ---
  Future<Map<String, dynamic>> submitWorkflowSetup({
    required int tenantId,
    required String template,
    required bool askName,
    required bool askLocation,
    required bool offerPayment,
    String? upiId,
    String? qrImageUrl,
  }) async {
    try {
      final body = {
        'tenant_id': tenantId.toString(),
        'template': template,
        'ask_name': askName.toString(),
        'ask_location': askLocation.toString(),
        'offer_payment': offerPayment.toString(),
        if (offerPayment) 'upi_id': upiId ?? '',
        if (offerPayment) 'qr_image_url': qrImageUrl ?? '',
      };

      final response = await _api.postForm('/onboarding/workflow', body);

      return response;
    } catch (e) {
      AppLogger.log('submitWorkflowSetup error: $e');
      return {'status': 'error', 'detail': e.toString()};
    }
  }

  /// --- Prefill UI fields (for WorkflowSetupScreen) ---
  Map<String, dynamic> getWorkflowDefaults() {
    final d = _data?.workflow;
    if (d == null) return {};

    return {
      'askName': d.askName ?? true,
      'askLocation': d.askLocation ?? false,
      'offerPayment': d.offerPayment ?? false,
      'upiId': d.upiId,
      'qrImageUrl': d.qrImageUrl,
      'template': d.template ??
          "Lead capture → Qualification → Payment", // fallback default
    };
  }

  Future<Map<String, dynamic>> saveAgentConfiguration({
    required int tenantId,
    required String agentName,
    required String status,
    required String preferredLanguages,
    required String conversationTone,
    required bool incomingVoiceMessageEnabled,
    required bool outgoingVoiceMessageEnabled,
    required bool incomingMediaMessageEnabled,
    required bool outgoingMediaMessageEnabled,
    required bool imageAnalyzerEnabled,
    required String agentImage,
  }) async {
    try {
      final payload = {
        "tenant_id": tenantId,
        "agent_name": agentName,
        "status": status,
        "preferred_languages": preferredLanguages,
        "conversation_tone": conversationTone,
        "incoming_voice_message_enabled": incomingVoiceMessageEnabled,
        "outgoing_voice_message_enabled": outgoingVoiceMessageEnabled,
        "incoming_media_message_enabled": incomingMediaMessageEnabled,
        "outgoing_media_message_enabled": outgoingMediaMessageEnabled,
        "image_analyzer_enabled": imageAnalyzerEnabled,
        "agent_image": agentImage,
      };

      final response = await _api.postJson('/onboarding/agent-configurations', payload);
      return response;
    } catch (e) {
      AppLogger.log('saveAgentConfiguration error: $e');
      return {'status': 'error', 'detail': e.toString()};
    }
  }

}

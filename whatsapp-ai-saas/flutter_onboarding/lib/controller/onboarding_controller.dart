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
    if (_data != null) return;

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
      final response = await _api.postForm('/onboarding/type', {
        'tenant_id': tenantId.toString(),
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

}
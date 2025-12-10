import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/models/campaign.dart';
import 'package:humainity_flutter/repositories/campaigns_repository.dart';
// Import your auth/profile providers to get the token/tenant_id
// import 'package:humainity_flutter/core/providers/auth_provider.dart';
// import 'package:humainity_flutter/core/providers/business_profile_provider.dart';

// 1. Create the Repository Provider
final campaignsRepositoryProvider = Provider<CampaignsRepository>((ref) {
  // TODO: Retrieve the actual Token and Tenant ID from your Auth/Profile providers
  // Example:
  // final user = ref.watch(authNotifierProvider).user;
  // final profile = ref.watch(businessProfileProvider).profile;

  const String token = "YOUR_AUTH_TOKEN"; // Replace with ref.watch(...)
  const int tenantId = 1; // Replace with ref.watch(...)

  return CampaignsRepository(token: token, tenantId: tenantId);
});

// 2. Define the AsyncNotifier Provider
final campaignsProvider = AsyncNotifierProvider<CampaignsNotifier, List<Campaign>>(() {
  return CampaignsNotifier();
});

class CampaignsNotifier extends AsyncNotifier<List<Campaign>> {
  late CampaignsRepository _repository;

  @override
  FutureOr<List<Campaign>> build() async {
    _repository = ref.watch(campaignsRepositoryProvider);
    return _fetchCampaigns();
  }

  Future<List<Campaign>> _fetchCampaigns() async {
    return await _repository.fetchCampaigns();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCampaigns());
  }

  Future<void> createCampaign({
    required String name,
    required String? description,
    required String channel,
    required int? templateId,
    required bool runImmediate,
    required PlatformFile file,
  }) async {
    // We don't set state to loading here to avoid full screen flicker,
    // the UI handles the button loading state.
    await _repository.createCampaign(
      name: name,
      description: description,
      channel: channel,
      templateId: templateId,
      runImmediate: runImmediate,
      file: file,
    );
    // Refresh the list after creation
    await refresh();
  }

  Future<void> updateStatus(int campaignId, String action) async {
    // Optimistic update could go here, but for now we just call API and refresh
    await _repository.updateStatus(campaignId, action);
    await refresh();
  }
}
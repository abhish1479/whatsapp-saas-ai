import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/storage/store_user_data.dart';
import 'package:humainise_ai/models/campaign.dart';
import 'package:humainise_ai/repositories/campaigns_repository.dart';
// Import your auth/profile providers to get the token/tenant_id
// import 'package:humainise_ai/core/providers/auth_provider.dart';
// import 'package:humainise_ai/core/providers/business_profile_provider.dart';

// 1. Create the Repository Provider
final campaignsRepositoryProvider = Provider<CampaignsRepository>((ref) {
  final storeUserData = ref.watch(storeUserDataProvider);
  return CampaignsRepository(storeUserData!);
});

// 2. Define the AsyncNotifier Provider
final campaignsProvider =
    AsyncNotifierProvider<CampaignsNotifier, List<Campaign>>(() {
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

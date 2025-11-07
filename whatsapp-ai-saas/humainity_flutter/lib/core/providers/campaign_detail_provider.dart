import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/campaigns_provider.dart'; // Import for repo provider
import 'package:humainity_flutter/models/campaign.dart';
import 'package:humainity_flutter/models/campaign_log.dart';

// 1. State (Unchanged)
class CampaignDetailState {
  final Campaign? campaign;
  final List<CampaignLog> logs;
  final bool isLoading;
  final String? error;

  CampaignDetailState({
    this.campaign,
    this.logs = const [],
    this.isLoading = true,
    this.error,
  });

  CampaignDetailState copyWith({
    Campaign? campaign,
    List<CampaignLog>? logs,
    bool? isLoading,
    String? error,
  }) {
    return CampaignDetailState(
      campaign: campaign ?? this.campaign,
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 2. Notifier (Refactored to use Repository)
class CampaignDetailNotifier extends StateNotifier<CampaignDetailState> {
  // *** REFACTOR ***
  final Ref _ref;
  final String _campaignId;

  CampaignDetailNotifier(this._ref, this._campaignId)
      : super(CampaignDetailState()) {
    fetchCampaignDetails();
    fetchCampaignLogs();
  }

  Future<void> fetchCampaignDetails() async {
    state = state.copyWith(isLoading: true);
    try {
      // *** REFACTOR ***
      final campaign = await _ref
          .read(campaignsRepositoryProvider)
          .fetchCampaignDetails(_campaignId);
      state = state.copyWith(campaign: campaign, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchCampaignLogs() async {
    try {
      // *** REFACTOR ***
      final logs = await _ref
          .read(campaignsRepositoryProvider)
          .fetchCampaignLogs(_campaignId);
      state = state.copyWith(logs: logs);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // *** FIX: Added updateStatus method ***
  Future<void> updateStatus(String newStatus) async {
    try {
      // Call the repository to update the status
      final updatedCampaign = await _ref
          .read(campaignsRepositoryProvider)
          .updateStatus(_campaignId, newStatus);

      // Update the local state of this detail provider
      state = state.copyWith(campaign: updatedCampaign);

      // *** IMPORTANT ***
      // Also, refresh the main campaigns list provider
      // so the change reflects on the main 'CampaignScreen'.
      _ref.read(campaignsProvider.notifier).fetchCampaigns();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // *** FIX: Added refreshData method ***
  Future<void> refreshData() async {
    // This can just call the original loading methods
    state = state.copyWith(isLoading: true);
    await fetchCampaignDetails();
    await fetchCampaignLogs();
    state = state.copyWith(isLoading: false);
  }
}

// 3. Provider (Unchanged structure, logic moved to Notifier)
final campaignDetailProvider = StateNotifierProvider.autoDispose
    .family<CampaignDetailNotifier, CampaignDetailState, String>(
      (ref, campaignId) {
    // *** REFACTOR *** - Just pass ref and ID now
    return CampaignDetailNotifier(ref, campaignId);
  },
);
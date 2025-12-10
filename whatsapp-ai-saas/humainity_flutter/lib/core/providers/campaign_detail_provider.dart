import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/models/campaign.dart';
import 'package:humainity_flutter/core/providers/campaigns_provider.dart';

// State class to hold the detail view data
class CampaignDetailState {
  final bool isLoading;
  final Campaign? campaign;
  final String? error;

  CampaignDetailState({
    this.isLoading = false,
    this.campaign,
    this.error,
  });

  CampaignDetailState copyWith({
    bool? isLoading,
    Campaign? campaign,
    String? error,
  }) {
    return CampaignDetailState(
      isLoading: isLoading ?? this.isLoading,
      campaign: campaign ?? this.campaign,
      error: error ?? this.error,
    );
  }
}

// Family provider to fetch details by ID (int)
final campaignDetailProvider =
StateNotifierProvider.autoDispose.family<CampaignDetailNotifier, CampaignDetailState, int>(
      (ref, campaignId) {
    return CampaignDetailNotifier(ref, campaignId);
  },
);

class CampaignDetailNotifier extends StateNotifier<CampaignDetailState> {
  final Ref ref;
  final int campaignId;

  CampaignDetailNotifier(this.ref, this.campaignId)
      : super(CampaignDetailState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    await refreshData();
  }

  Future<void> refreshData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final repository = ref.read(campaignsRepositoryProvider);
      final campaign = await repository.fetchCampaignDetails(campaignId);

      // Note: We removed fetchCampaignLogs from the repo for now

      state = state.copyWith(
        isLoading: false,
        campaign: campaign,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStatus(String action) async {
    try {
      final repository = ref.read(campaignsRepositoryProvider);
      await repository.updateStatus(campaignId, action);

      // Refresh to get the new status from server
      await refreshData();

      // Also refresh the main list so the previous screen is up to date
      ref.refresh(campaignsProvider);
    } catch (e) {
      // Handle error (maybe show toast in UI)
      state = state.copyWith(error: "Failed to update status: $e");
    }
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/supabase_provider.dart';
import 'package:humainity_flutter/models/campaign.dart';
import 'package:humainity_flutter/models/template.dart';
// *** REFACTOR *** - Import repositories
import 'package:humainity_flutter/repositories/campaigns_repository.dart';
import 'package:humainity_flutter/repositories/templates_repository.dart';

// *** REFACTOR ***
// Provider for the CampaignsRepository
final campaignsRepositoryProvider = Provider<CampaignsRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CampaignsRepository(supabase);
});

// Provider for the TemplatesRepository
// This can be defined here or in a dedicated templates_provider.dart if it doesn't exist
final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return TemplatesRepository(supabase);
});

// 1. State (Unchanged)
class CampaignsState {
  final List<Campaign> campaigns;
  final List<MessageTemplate> templates;
  final bool isLoading;
  final String? error;

  CampaignsState({
    this.campaigns = const [],
    this.templates = const [],
    this.isLoading = false,
    this.error,
  });

  CampaignsState copyWith({
    List<Campaign>? campaigns,
    List<MessageTemplate>? templates,
    bool? isLoading,
    String? error,
  }) {
    return CampaignsState(
      campaigns: campaigns ?? this.campaigns,
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 2. Notifier (Refactored to use Repositories)
class CampaignsNotifier extends StateNotifier<CampaignsState> {
  final Ref _ref;
  // *** REFACTOR ***
  final CampaignsRepository _campaignsRepository;
  final TemplatesRepository _templatesRepository;

  CampaignsNotifier(
      this._ref, this._campaignsRepository, this._templatesRepository)
      : super(CampaignsState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);
    try {
      // *** REFACTOR *** - Use repository methods
      final campaignsFuture = _campaignsRepository.fetchCampaigns();
      final templatesFuture =
      _templatesRepository.fetchTemplates(type: 'outbound');

      final results = await Future.wait([campaignsFuture, templatesFuture]);

      state = state.copyWith(
        campaigns: results[0] as List<Campaign>,
        templates: results[1] as List<MessageTemplate>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchCampaigns() async {
    try {
      // *** REFACTOR ***
      final campaigns = await _campaignsRepository.fetchCampaigns();
      state = state.copyWith(campaigns: campaigns, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchTemplates() async {
    try {
      // *** REFACTOR ***
      final templates = await _templatesRepository.fetchTemplates(type: 'outbound');
      state = state.copyWith(templates: templates, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createCampaign(Map<String, dynamic> formData) async {
    try {
      // *** REFACTOR ***
      final newCampaign = await _campaignsRepository.createCampaign(formData);
      state = state.copyWith(campaigns: [newCampaign, ...state.campaigns]);
    } catch (e) {
      print('Error adding campaign: $e');
      rethrow;
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    try {
      // *** REFACTOR ***
      final updatedCampaign =
      await _campaignsRepository.updateStatus(id, newStatus);
      state = state.copyWith(
          campaigns: state.campaigns
              .map((c) => c.id == id ? updatedCampaign : c)
              .toList());
    } catch (e) {
      print('Error updating status: $e');
      rethrow;
    }
  }

  Future<void> deleteCampaign(String id) async {
    try {
      // *** REFACTOR ***
      await _campaignsRepository.deleteCampaign(id);
      state = state.copyWith(
          campaigns: state.campaigns.where((c) => c.id != id).toList());
    } catch (e) {
      print('Error deleting campaign: $e');
      rethrow;
    }
  }
}

// 3. Provider (Refactored to inject Repositories)
final campaignsProvider =
StateNotifierProvider<CampaignsNotifier, CampaignsState>((ref) {
  // *** REFACTOR ***
  final campaignsRepo = ref.watch(campaignsRepositoryProvider);
  final templatesRepo = ref.watch(templatesRepositoryProvider);
  return CampaignsNotifier(ref, campaignsRepo, templatesRepo);
});

// ADDED providers for filtering campaigns by channel (Unchanged)
final whatsappCampaignsProvider = Provider<List<Campaign>>((ref) {
  final state = ref.watch(campaignsProvider);
  return state.campaigns.where((c) => c.channel == 'whatsapp').toList();
});

final voiceCampaignsProvider = Provider<List<Campaign>>((ref) {
  final state = ref.watch(campaignsProvider);
  return state.campaigns.where((c) => c.channel == 'voice').toList();
});
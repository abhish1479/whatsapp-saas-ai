import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/models/customer.dart';
import 'package:humainity_flutter/models/customer_campaign.dart';
import 'package:humainity_flutter/models/engagement.dart';
import 'package:humainity_flutter/models/payment.dart';
import 'package:humainity_flutter/models/saved_filter_list.dart';
import 'package:humainity_flutter/repositories/crm_repository.dart';
import 'package:humainity_flutter/core/providers/supabase_provider.dart'; // We still need this to create the repo provider

// 1. State (Unchanged)
class CrmState {
  final List<Customer> customers;
  final List<SavedFilterList> savedLists;
  final Map<String, List<Engagement>> previewEngagements;
  final Map<String, List<Payment>> previewPayments;
  final Map<String, List<CustomerCampaign>> previewCampaigns;
  final bool isLoading;
  final String? error;

  CrmState({
    this.customers = const [],
    this.savedLists = const [],
    this.previewEngagements = const {},
    this.previewPayments = const {},
    this.previewCampaigns = const {},
    this.isLoading = false,
    this.error,
  });

  CrmState copyWith({
    List<Customer>? customers,
    List<SavedFilterList>? savedLists,
    Map<String, List<Engagement>>? previewEngagements,
    Map<String, List<Payment>>? previewPayments,
    Map<String, List<CustomerCampaign>>? previewCampaigns,
    bool? isLoading,
    String? error,
    bool? clearError,
  }) {
    return CrmState(
      customers: customers ?? this.customers,
      savedLists: savedLists ?? this.savedLists,
      previewEngagements: previewEngagements ?? this.previewEngagements,
      previewPayments: previewPayments ?? this.previewPayments,
      previewCampaigns: previewCampaigns ?? this.previewCampaigns,
      isLoading: isLoading ?? this.isLoading,
      error: clearError == true ? null : error ?? this.error,
    );
  }
}

// *** REFACTOR ***
// Provider for the CrmRepository
final crmRepositoryProvider = Provider<CrmRepository>((ref) {
  // The repository depends on the Supabase client
  final supabase = ref.watch(supabaseClientProvider);
  return CrmRepository(supabase);
});

// 2. Notifier (Refactored to use Repository)
class CrmNotifier extends StateNotifier<CrmState> {
  final Ref _ref;
  final CrmRepository _repository; // *** REFACTOR ***

  CrmNotifier(this._ref, this._repository) : super(CrmState()) { // *** REFACTOR ***
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);
    try {
      // *** REFACTOR *** - Use repository methods
      final customersFuture = _repository.fetchCustomers();
      final listsFuture = _repository.fetchSavedLists();

      final results = await Future.wait([customersFuture, listsFuture]);

      state = state.copyWith(
        customers: results[0] as List<Customer>,
        savedLists: results[1] as List<SavedFilterList>,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchCustomers() async {
    try {
      // *** REFACTOR ***
      final customers = await _repository.fetchCustomers();
      state = state.copyWith(customers: customers, clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> fetchSavedLists() async {
    try {
      // *** REFACTOR ***
      final lists = await _repository.fetchSavedLists();
      state = state.copyWith(savedLists: lists, clearError: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addCustomer(Map<String, dynamic> formData) async {
    try {
      // *** REFACTOR ***
      final newCustomer = await _repository.addCustomer(formData);
      state = state.copyWith(customers: [newCustomer, ...state.customers]);
    } catch (e) {
      print('Error adding customer: $e');
      rethrow;
    }
  }

  Future<void> updateCustomerStatus(String customerId, String newStatus) async {
    try {
      // *** REFACTOR ***
      final updatedCustomer =
      await _repository.updateCustomerStatus(customerId, newStatus);
      state = state.copyWith(
          customers: state.customers
              .map((c) => c.id == customerId ? updatedCustomer : c)
              .toList());
    } catch (e) {
      print('Error updating status: $e');
      rethrow;
    }
  }

  Future<void> fetchCustomerPreviewDetails(String customerId) async {
    try {
      // *** REFACTOR *** - Use repository methods
      final engagementsFuture = _repository.fetchEngagements(customerId);
      final paymentsFuture = _repository.fetchPayments(customerId);
      final campaignsFuture = _repository.fetchCampaigns(customerId);

      final results =
      await Future.wait([engagementsFuture, paymentsFuture, campaignsFuture]);

      final engagements = results[0] as List<Engagement>;
      final payments = results[1] as List<Payment>;
      final campaigns = results[2] as List<CustomerCampaign>;

      state = state.copyWith(
        previewEngagements: {...state.previewEngagements, customerId: engagements},
        previewPayments: {...state.previewPayments, customerId: payments},
        previewCampaigns: {...state.previewCampaigns, customerId: campaigns},
      );
    } catch (e) {
      print('Error fetching preview details: $e');
    }
  }

  Future<void> addEngagement(Map<String, dynamic> formData) async {
    try {
      // *** REFACTOR ***
      final newEngagement = await _repository.addEngagement(formData);
      final customerId = formData['customer_id'];

      final List<Engagement> updatedEngagements = [
        newEngagement,
        ...state.previewEngagements[customerId] ?? []
      ];

      state = state.copyWith(
          previewEngagements: {
            ...state.previewEngagements,
            customerId: updatedEngagements
          });
      // Also refetch customer list to update total_interactions
      await fetchCustomers();
    } catch (e) {
      print('Error logging engagement: $e');
      rethrow;
    }
  }
}

// 3. Provider (Refactored to inject Repository)
final crmProvider = StateNotifierProvider<CrmNotifier, CrmState>((ref) {
  // *** REFACTOR ***
  // The Notifier now depends on the Repository.
  final repository = ref.watch(crmRepositoryProvider);
  return CrmNotifier(ref, repository);
});
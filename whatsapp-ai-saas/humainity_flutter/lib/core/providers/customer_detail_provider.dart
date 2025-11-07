import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/crm_provider.dart'; // Import for repo provider
import 'package:humainity_flutter/models/customer.dart';
import 'package:humainity_flutter/models/customer_campaign.dart';
import 'package:humainity_flutter/models/engagement.dart';
import 'package:humainity_flutter/models/payment.dart';

// 1. State (Unchanged)
class CustomerDetailState {
  final Customer? customer;
  final List<Engagement> engagements;
  final List<Payment> payments;
  final List<CustomerCampaign> campaigns;
  final bool isLoading;
  final String? error;

  CustomerDetailState({
    this.customer,
    this.engagements = const [],
    this.payments = const [],
    this.campaigns = const [],
    this.isLoading = true,
    this.error,
  });

  CustomerDetailState copyWith({
    Customer? customer,
    List<Engagement>? engagements,
    List<Payment>? payments,
    List<CustomerCampaign>? campaigns,
    bool? isLoading,
    String? error,
  }) {
    return CustomerDetailState(
      customer: customer ?? this.customer,
      engagements: engagements ?? this.engagements,
      payments: payments ?? this.payments,
      campaigns: campaigns ?? this.campaigns,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 2. Notifier (Refactored to use Repository)
class CustomerDetailNotifier extends StateNotifier<CustomerDetailState> {
  // *** REFACTOR ***
  final Ref _ref;
  final String _customerId;

  CustomerDetailNotifier(this._ref, this._customerId)
      : super(CustomerDetailState()) {
    loadAllDetails();
  }

  Future<void> loadAllDetails() async {
    state = state.copyWith(isLoading: true);
    try {
      // *** REFACTOR ***
      final repo = _ref.read(crmRepositoryProvider);

      // Use Future.wait to fetch all details concurrently
      final customerFuture = repo.fetchCustomerById(_customerId);
      final engagementsFuture = repo.fetchEngagements(_customerId);
      final paymentsFuture = repo.fetchPayments(_customerId);
      final campaignsFuture = repo.fetchCampaigns(_customerId);

      final results = await Future.wait([
        customerFuture,
        engagementsFuture,
        paymentsFuture,
        campaignsFuture,
      ]);

      state = state.copyWith(
        customer: results[0] as Customer,
        engagements: results[1] as List<Engagement>,
        payments: results[2] as List<Payment>,
        campaigns: results[3] as List<CustomerCampaign>,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // *** REFACTOR ***
  // Add specific refresh methods that can be called by the UI
  Future<void> refreshEngagements() async {
    try {
      final engagements =
      await _ref.read(crmRepositoryProvider).fetchEngagements(_customerId);
      state = state.copyWith(engagements: engagements);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshCustomer() async {
    try {
      final customer =
      await _ref.read(crmRepositoryProvider).fetchCustomerById(_customerId);
      state = state.copyWith(customer: customer);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// 3. Provider (Unchanged structure, logic moved to Notifier)
final customerDetailProvider = StateNotifierProvider.autoDispose
    .family<CustomerDetailNotifier, CustomerDetailState, String>(
      (ref, customerId) {
    return CustomerDetailNotifier(ref, customerId);
  },
);
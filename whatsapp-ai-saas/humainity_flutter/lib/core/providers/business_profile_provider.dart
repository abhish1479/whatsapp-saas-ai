import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/storage/store_user_data.dart';
import 'package:humainise_ai/models/business_profile.dart';
import 'package:humainise_ai/repositories/business_profile_repository.dart';

// --- State Class ---
class BusinessProfileState {
  final bool isLoading;
  final BusinessProfile? profile;
  final String? error;

  BusinessProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
  });

  factory BusinessProfileState.initial() => BusinessProfileState();

  BusinessProfileState copyWith({
    bool? isLoading,
    BusinessProfile? profile,
    String? error,
  }) {
    return BusinessProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

// --- Notifier Class ---
class BusinessProfileNotifier extends StateNotifier<BusinessProfileState> {
  final BusinessProfileRepository _repo;
  final StoreUserData? _store;

  BusinessProfileNotifier(this._repo, this._store)
      : super(BusinessProfileState.initial());

  /// Loads the profile for the current tenant
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tenantIdStr = await _store?.getTenantId();
      if (tenantIdStr == null) {
        // Not logged in or no tenant ID
        state = state.copyWith(isLoading: false);
        return;
      }

      final tenantId = int.parse(tenantIdStr);
      final profile = await _repo.getBusinessProfile(tenantId);
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new profile (Onboarding)
  Future<void> createProfile(BusinessProfileCreate payload) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newProfile = await _repo.createBusinessProfile(payload);
      state = state.copyWith(isLoading: false, profile: newProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow; // Allow UI to handle success/failure notification
    }
  }

  /// Update existing profile
  Future<void> updateProfile(BusinessProfileUpdate payload) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedProfile = await _repo.updateBusinessProfile(payload);
      state = state.copyWith(isLoading: false, profile: updatedProfile);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

// --- Provider Definition ---
final businessProfileProvider =
    StateNotifierProvider<BusinessProfileNotifier, BusinessProfileState>((ref) {
  final repo = ref.watch(businessProfileRepositoryProvider);
  final store = ref.watch(storeUserDataProvider);
  return BusinessProfileNotifier(repo, store);
});

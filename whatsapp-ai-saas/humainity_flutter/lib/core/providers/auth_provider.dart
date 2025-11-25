import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/repositories/auth_repository.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isInitialized: isInitialized ?? this.isInitialized,
      );

  factory AuthState.initial() => const AuthState(isAuthenticated: false);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final StoreUserData? _storeUserData;
  final StreamController<AuthState> streamController =
      StreamController<AuthState>.broadcast();

  AuthNotifier(this._repo, this._storeUserData) : super(AuthState.initial()) {
    // NEW: Trigger initial check when the notifier is created
    initialize();
  }

  // NEW: Method to check stored credentials on app startup
  Future<void> initialize() async {
    try {
      final isAuthenticated = await _repo.getAuthStatus();
      _emit(state.copyWith(
        isAuthenticated: isAuthenticated,
        isInitialized: true,
        isLoading: false,
      ));
    } catch (_) {
      _emit(state.copyWith(
        isAuthenticated: false,
        isInitialized: true,
        isLoading: false,
      ));
    }
  }

  void _emit(AuthState newState) {
    state = newState;
    streamController.add(newState);
  }

  Future<void> _maybeFetchOnboardingStatus() async {
    if (_storeUserData == null) return;

    final onboardingProcess = await _storeUserData!.getOnboardingProcess();
    if (onboardingProcess != 'InProcess') return;
    final tenantId = await _storeUserData!.getTenantId();
    if (tenantId == null || tenantId.isEmpty) return;

    final id = int.tryParse(tenantId);
    if (id == null) return;
    final status = await _repo.getOnboardingStatus(id);
    if (status["data"] != null && status["data"]["onboarding_steps"] != null) {
      await _storeUserData!.saveOnboardingSteps(
        Map<String, dynamic>.from(status["data"]["onboarding_steps"]),
      );
    }

    if (status["data"]?["onboarding_process"] == "Completed") {
      await _storeUserData!.setOnboardingProcess("Completed");
    }
  }

  Future<void> signIn(String email, String password) async {
    _emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repo.signIn(email, password);
      // NEW: if onboarding_process == "InProcess", fetch onboarding status
      await _maybeFetchOnboardingStatus();
      _emit(state.copyWith(isAuthenticated: true, isLoading: false));
    } catch (e) {
      _emit(state.copyWith(
          error: e.toString(), isAuthenticated: false, isLoading: false));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String businessName,
  }) async {
    _emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repo.signUp(
          email: email, password: password, businessName: businessName);
      // NEW: if onboarding_process == "InProcess", fetch onboarding status
      await _maybeFetchOnboardingStatus();
      _emit(state.copyWith(isAuthenticated: true, isLoading: false));
    } catch (e) {
      _emit(state.copyWith(
          error: e.toString(), isAuthenticated: false, isLoading: false));
    }
  }

  Future<void> signInWithGoogle(String idToken, bool isLogin) async {
    _emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repo.socialSignIn(
        idToken: idToken,
        provider: 'google',
        isLogin: isLogin,
      );
      // NEW: if onboarding_process == "InProcess", fetch onboarding status
      await _maybeFetchOnboardingStatus();
      _emit(state.copyWith(isAuthenticated: true, isLoading: false));
    } catch (e) {
      _emit(state.copyWith(
          error: e.toString(), isAuthenticated: false, isLoading: false));
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _emit(state.copyWith(isAuthenticated: false));
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // 1. Get the repository (which already has StoreUserData injected via its provider)
  final repository = ref.watch(authRepositoryProvider);

  // 2. We still need direct access to StoreUserData here for _loadInitialAuthData
  // Note: The watch handles the potential null state of storeUserDataProvider
  final storeUserData = ref.watch(storeUserDataProvider);

  // 3. Instantiate the Notifier with both dependencies
  return AuthNotifier(repository, storeUserData);
});

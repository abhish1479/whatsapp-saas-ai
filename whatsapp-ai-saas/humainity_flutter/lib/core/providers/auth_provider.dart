import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/repositories/auth_repository.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isInitialized; // NEW: Indicates if initial check is complete
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.isInitialized = false, // Initialize as false
    this.error
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool? isInitialized, // Add to copyWith
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isInitialized: isInitialized ?? this.isInitialized, // Update state
      );

  factory AuthState.initial() => const AuthState(isAuthenticated: false);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final StreamController<AuthState> streamController = StreamController<AuthState>.broadcast();

  AuthNotifier(this._repo) : super(AuthState.initial()) {
    // NEW: Trigger initial check when the notifier is created
    initialize(); 
  }

  // NEW: Method to check stored credentials on app startup
  Future<void> initialize() async {
    try {
      final isAuthenticated = await _repo.getAuthStatus();
      _emit(state.copyWith(
        isAuthenticated: isAuthenticated,
        isInitialized: true, // Mark as initialized
        isLoading: false,
      ));
    } catch (_) {
      // If any error occurs during check (e.g., local storage read fail),
      // we assume the user is not logged in but mark initialization complete.
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

  Future<void> signIn(String email, String password) async {
    _emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repo.signIn(email, password);
      _emit(state.copyWith(isAuthenticated: true, isLoading: false));
    } catch (e) {
      _emit(state.copyWith(error: e.toString(), isAuthenticated: false, isLoading: false));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String businessName,
  }) async {
    _emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repo.signUp(email: email, password: password, businessName: businessName);
      _emit(state.copyWith(isAuthenticated: true, isLoading: false));
    } catch (e) {
      _emit(state.copyWith(error: e.toString(), isAuthenticated: false, isLoading: false));
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
      _emit(state.copyWith(isAuthenticated: true, isLoading: false));
    } catch (e) {
      _emit(state.copyWith(error: e.toString(), isAuthenticated: false, isLoading: false));
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

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // AuthNotifier constructor calls initialize()
  return AuthNotifier(AuthRepository());
});
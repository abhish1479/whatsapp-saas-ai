import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/providers/supabase_provider.dart';
import 'package:humainity_flutter/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

// StreamProvider for the real-time auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

// State for the AuthNotifier (tracking loading/errors)
class AuthScreenState {
  final bool isLoading;
  final String? error;

  AuthScreenState({this.isLoading = false, this.error});

  AuthScreenState copyWith({bool? isLoading, String? error}) {
    return AuthScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier for handling auth actions (login, signup)
class AuthNotifier extends StateNotifier<AuthScreenState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthScreenState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signIn(email, password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      // Rethrow to be caught by the UI if needed
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signUp(email: email, password: password, data: data);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

// Provider for the AuthNotifier
final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthScreenState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
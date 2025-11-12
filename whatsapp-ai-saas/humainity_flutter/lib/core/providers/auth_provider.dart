import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/repositories/auth_repository.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  const AuthState({required this.isAuthenticated, this.isLoading = false, this.error});

  AuthState copyWith({bool? isAuthenticated, bool? isLoading, String? error}) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  factory AuthState.initial() => const AuthState(isAuthenticated: false);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final StreamController<AuthState> streamController = StreamController<AuthState>.broadcast();

  AuthNotifier(this._repo) : super(AuthState.initial());

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
  return AuthNotifier(AuthRepository());
});

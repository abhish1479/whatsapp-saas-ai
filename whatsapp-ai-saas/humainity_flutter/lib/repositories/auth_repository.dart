import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Handle or rethrow the error
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: data, // Additional user metadata
      );
      // Supabase may send a confirmation email, user won't be logged in
      // until they confirm (depending on your Supabase settings).
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
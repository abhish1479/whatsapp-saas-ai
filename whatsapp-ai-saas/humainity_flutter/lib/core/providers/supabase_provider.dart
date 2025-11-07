import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// This provider is now simplified to only expose the Supabase client.
// The Auth state stream has been moved to auth_provider.dart for clarity.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
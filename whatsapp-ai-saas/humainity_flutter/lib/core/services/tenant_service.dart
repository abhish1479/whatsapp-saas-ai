import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantService {
  // We'll use '1' as the default/hardcoded tenant ID for now
  static const String _hardcodedTenantId = '1';

  Future<String> getTenantId() async {
    // In the future, you can replace this logic
    // e.g., final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('tenant_id') ?? _hardcodedTenantId;

    // For now, just return the hardcoded value as requested.
    return _hardcodedTenantId;
  }
}

final tenantServiceProvider = Provider<TenantService>((ref) {
  return TenantService();
});
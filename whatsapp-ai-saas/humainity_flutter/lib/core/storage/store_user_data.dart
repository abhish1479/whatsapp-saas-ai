import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});
final onboardingRefreshProvider = StateProvider<int>((ref) => 0);

class StoreUserData {
  final SharedPreferences _prefs;
  StoreUserData(this._prefs);

  Future<void> setToken(String token) async {
    await _prefs.setString('token', token);
  }

  Future<void> setTenantId(String tenantId) async {
    await _prefs.setString('tenant_id', tenantId);
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('is_logged_in', value);
  }

  Future<void> setUserName(String name) async {
    await _prefs.setString('user_name', name);
  }

  Future<void> setEmail(String email) async {
    await _prefs.setString('email', email);
  }

  Future<void> setProfilePic(String? url) async {
    if (url != null) {
      await _prefs.setString('profile_pic', url);
    }
  }

  Future<void> setOnboardingProcess(String? onboardingProcess) async {
    if (onboardingProcess != null) {
      await _prefs.setString('onboarding_process', onboardingProcess);
    }
  }

  Future<void> saveOnboardingSteps(Map<String, dynamic> steps) async {
    if (steps.isEmpty) return;
    await _prefs.setString('onboarding_steps', jsonEncode(steps));
  }


  Future<String?> getToken() async {
    return _prefs.getString('token');
  }

  Future<String?> getTenantId() async {
    return _prefs.getString('tenant_id');
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool('is_logged_in') ?? false;
  }

  Future<String?> getUserName() async {
    return _prefs.getString('user_name');
  }

  Future<String?> getEmail() async {
    return _prefs.getString('email');
  }

  Future<String?> getProfilePic() async {
    return _prefs.getString('profile_pic');
  }

  Future<String?> getOnboardingProcess() async {
    return _prefs.getString('onboarding_process');
  }

  Future<Map<String, bool>> getOnboardingSteps() async {
    final data = _prefs.getString('onboarding_steps');
    if (data == null) {
      return {
        'AI_Agent_Configuration': false,
        'Knowledge_Base_Ingestion': false,
        'template_Messages_Setup': false,
      };
    }
    try {
      final decodedMap = jsonDecode(data) as Map<String, dynamic>;
      return decodedMap.map(
        (key, value) => MapEntry(key, value == true),
      );
    } catch (_) {
      return {
        'AI_Agent_Configuration': false,
        'Knowledge_Base_Ingestion': false,
        'template_Messages_Setup': false,
      };
    }
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}

final storeUserDataProvider = Provider<StoreUserData?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  return prefsAsync.when(
    data: (prefs) => StoreUserData(prefs),
    loading: () => null,
    error: (e, s) => null,
  );
});

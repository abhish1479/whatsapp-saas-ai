import 'package:shared_preferences/shared_preferences.dart';

class StoreUserData {
  // ----------- WRITE DATA -----------
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> setTenantId(String tenantId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tenant_id', tenantId);
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', value);
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  Future<void> setProfilePic(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url != null) await prefs.setString('profile_pic', url);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('tenant_id');
    await prefs.remove('is_logged_in');
    await prefs.remove('user_name');
    await prefs.remove('email');
    await prefs.remove('profile_pic');
  }

  // ----------- READ DATA -----------
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getTenantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tenant_id');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<String?> getProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_pic');
  }
}

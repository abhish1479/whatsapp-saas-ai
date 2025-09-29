import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class StoreUserData {
// Singleton pattern to ensure a single instance throughout the app
  static final StoreUserData _instance = StoreUserData._internal();

  factory StoreUserData() {
    return _instance;
  }

  StoreUserData._internal();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Store a boolean value in shared preferences
  Future<void> setLoggedIn(bool value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool('LoggedIn', value);
  }

  // Retrieve a boolean value from shared preferences
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool('LoggedIn') ?? false;
  }

  Future<void> clear() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.clear();
  }

  // Store a string value in shared preferences
  Future<void> setTenantId(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('TenantId', value);
  }

  // Retrieve a string value from shared preferences
  Future<String> getTenantId() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('TenantId') ?? '';
  }


}

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
  Future<void> setTenantId(int value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt('TenantId', value);
  }

  // Retrieve a string value from shared preferences
  Future<int> getTenantId() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt('TenantId') ?? -1;
  }

  // Store a string value in shared preferences
  Future<void> setUserStatus(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('UserStatus', value);
  }

  // Retrieve a string value from shared preferences
  Future<String> getUserStatus() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('UserStatus') ?? '';
  }

  // Store a string value in shared preferences
  Future<void> setToken(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('Token', value);
  }

  // Retrieve a string value from shared preferences
  Future<String> getToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('Token') ?? '';
  }

  // Store a string value in shared preferences
  Future<void> setUserName(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('UserName', value);
  }

  // Retrieve a string value from shared preferences
  Future<String> getUserName() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('UserName') ?? '';
  }

  // Store a string value in shared preferences
  Future<void> setEmail(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('Email', value);
  }

  // Retrieve a string value from shared preferences
  Future<String> getEmail() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('Email') ?? '';
  }

  // Store a string value in shared preferences
  Future<void> setProfilePic(String value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('ProfilePic', value);
  }

  // Retrieve a string value from shared preferences
  Future<String> getProfilePic() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('ProfilePic') ?? '';
  }


}

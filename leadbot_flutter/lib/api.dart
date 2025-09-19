import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class Api {
  static const String baseUrl = "http://10.0.2.2:8000"; // Android Emulator
  static String getUrl(String path) => "$baseUrl$path";

  static Future<http.Response> post(String path, Map body) async {
    final token = await AuthService.getToken();
    return await http.post(Uri.parse(getUrl(path)),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token"
        },
        body: jsonEncode(body));
  }

  static Future<http.Response> get(String path) async {
    final token = await AuthService.getToken();
    return await http.get(Uri.parse(getUrl(path)), headers: {
      if (token != null) "Authorization": "Bearer $token"
    });
  }
}

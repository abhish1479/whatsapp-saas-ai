import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:humainity_flutter/core/utils/toast_service.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/core/utils/api_exception.dart';

class ApiClient {
  final StoreUserData? _store;

  ApiClient(this._store);

  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) throw Exception('Missing API_BASE_URL');
    return url;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _store?.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- HTTP Methods ---

  Future<dynamic> get(String endpoint, {bool silent = true}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response, silent: silent);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body, bool silent = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null
      );
      return _handleResponse(response, silent: silent);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body, bool silent = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null
      );
      return _handleResponse(response, silent: silent);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ ADDED: Delete Method
  // 'silent' defaults to false, so it WILL show a success message by default.
  // To hide the message, call it like: _api.delete('/items/1', silent: true);
  Future<dynamic> delete(String endpoint, {dynamic body, bool silent = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.delete(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null
      );
      return _handleResponse(response, silent: silent);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- Response Handler ---

  dynamic _handleResponse(http.Response response, {required bool silent}) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body);
    } catch (_) {
      throw _handleError("Server Error: ${response.statusCode}");
    }

    final bool isSuccess = json['success'] == true;
    final String? message = json['message'];

    if (isSuccess) {
      // Show toast only if NOT silent and message exists
      if (!silent && message != null && message.isNotEmpty) {
        ToastService.showSuccess(message);
      }
      return json['data'];
    } else {
      String errorMessage = message ?? 'Something went wrong';

      if (json['error'] != null && json['error'] is Map) {
        final errorObj = json['error'];
        if (errorObj['details'] is List) {
          final details = List<String>.from(errorObj['details']);
          if (details.isNotEmpty) {
            errorMessage = details.join('\n');
          }
        }
      }

      ToastService.showError(errorMessage);
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;

    // Check for common socket exceptions (network offline)
    final msg = "Network Error: Please check your connection.";
    ToastService.showError(msg);
    return ApiException(msg);
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:humainise_ai/core/utils/toast_service.dart';
import 'package:humainise_ai/core/storage/store_user_data.dart';
import 'package:humainise_ai/core/utils/api_exception.dart';

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

  Future<dynamic> post(String endpoint,
      {dynamic body, bool silent = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.post(uri,
          headers: headers, body: body != null ? jsonEncode(body) : null);
      return _handleResponse(response, silent: silent);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint,
      {dynamic body, bool silent = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.put(uri,
          headers: headers, body: body != null ? jsonEncode(body) : null);
      return _handleResponse(response, silent: silent);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ✅ ADDED: Delete Method
  // 'silent' defaults to false, so it WILL show a success message by default.
  // To hide the message, call it like: _api.delete('/items/1', silent: true);
  Future<dynamic> delete(String endpoint,
      {dynamic body, bool silent = false}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await _getHeaders();
    try {
      final response = await http.delete(uri,
          headers: headers, body: body != null ? jsonEncode(body) : null);
      return _handleResponse(response, silent: silent);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- Response Handler ---

  dynamic _handleResponse(http.Response response, {required bool silent}) {
    // Check for non-200/successful status codes first.
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Try to parse error message from body, otherwise use a generic one.
      String errorMessage = 'Request failed with status: ${response.statusCode}';
      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson is Map<String, dynamic>) {
          // Look for common error message keys
          if (errorJson.containsKey('detail')) {
            errorMessage = errorJson['detail'];
          } else if (errorJson.containsKey('message')) {
            errorMessage = errorJson['message'];
          }
        }
      } catch (e) {
        // Not a JSON error body, or parsing failed. The default message is fine.
      }
      ToastService.showError(errorMessage);
      throw ApiException(errorMessage, response.statusCode);
    }

    // Handle successful responses (2xx)
    try {
      // If body is empty, return null (e.g. for a 204 No Content)
      if (response.body.isEmpty) {
        return null;
      }

      final json = jsonDecode(response.body);

      // If it's an enveloped response, unpack it.
      if (json is Map<String, dynamic> &&
          json.containsKey('success') &&
          json.containsKey('data')) {
        if (json['success'] == true) {
          final String? message = json['message'];
          if (!silent && message != null && message.isNotEmpty) {
            ToastService.showSuccess(message);
          }
          return json['data'];
        } else {
          // The success flag is false in the envelope
          final String errorMessage = json['message'] ?? 'An error occurred.';
          ToastService.showError(errorMessage);
          throw ApiException(errorMessage, response.statusCode);
        }
      }

      // If it's not an enveloped response (raw list or map), return it directly.
      return json;
    } catch (e) {
      // This catches JSON parsing errors on successful status codes
      throw _handleError("Failed to process server response.");
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

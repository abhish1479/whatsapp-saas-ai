// lib/api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:leadbot_client/helper/utils/shared_preference.dart';

class Api {
  final String baseUrl;
  final Duration timeout;
  Api(this.baseUrl, {this.timeout = const Duration(seconds: 20)});

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> getJson(String path) async {
    final res = await http.get(_u(path)).timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty
          ? {}
          : json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> postJson(
      String path, Map<String, dynamic> body) async {
    final res = await http
        .post(_u(path),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body))
        .timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty
          ? {}
          : json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> postForm(
      String path, Map<String, String> body) async {
    final res = await http.post(_u(path), body: body).timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty
          ? {}
          : json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  /// CSV upload using multipart/form-data
Future<Map<String, dynamic>> uploadCsv(
  String path, {
  required String filename,
  required List<int> bytes,
  Map<String, String>? fields,
}) async {
  final tid = await StoreUserData().getTenantId();
  final allFields = Map<String, String>.from(fields ?? {});
  if (tid != null && !allFields.containsKey('tenant_id')) {
    allFields['tenant_id'] = tid;
  }

  final req = http.MultipartRequest('POST', _u(path))
    ..fields.addAll(allFields)
    ..files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
      contentType: MediaType('text', 'csv'),
    ));

  final streamed = await req.send().timeout(timeout);
  final res = await http.Response.fromStream(streamed);

  if (res.statusCode >= 200 && res.statusCode < 300) {
    return res.body.isEmpty
        ? {}
        : json.decode(res.body) as Map<String, dynamic>;
  }

  throw Exception(
    'CSV upload failed: ${res.statusCode} - ${res.reasonPhrase}\n${res.body}',
  );
}
}
// lib/api.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Api {
  final String baseUrl;
  final Duration timeout;

  Api(this.baseUrl, {this.timeout = const Duration(seconds: 20)});

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> getJson(String path) async {
    final res = await http.get(_u(path)).timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? {} : json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final res = await http
        .post(_u(path), headers: {'Content-Type': 'application/json'}, body: json.encode(body))
        .timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? {} : json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> postForm(String path, Map<String, String> body) async {
    final res = await http.post(_u(path), body: body).timeout(timeout);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? {} : json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  /// CSV upload (web/mobile)
  Future<Map<String, dynamic>> uploadCsv(String path, {required String filename, required List<int> bytes, Map<String, String>? fields}) async {
    final req = http.MultipartRequest('POST', _u(path));
    if (fields != null) req.fields.addAll(fields);
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename, contentType: MediaTypeCsv));
    final streamed = await req.send().timeout(timeout);
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? {} : json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('CSV upload failed: ${res.statusCode} ${res.body}');
  }
}

// tiny helper for content-type
class MediaTypeCsv implements http.Client {
  static final _ct = {'content-type': 'text/csv'};
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

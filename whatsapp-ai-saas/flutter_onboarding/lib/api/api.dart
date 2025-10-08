import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:leadbot_client/helper/utils/shared_preference.dart';

import '../helper/utils/app_loger.dart';


class Api {
  final String baseUrl;
  final Duration timeout;
  Api(this.baseUrl, {this.timeout = const Duration(seconds: 20)});

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = _u(path);
    final headers = <String, String>{'Content-Type': 'application/json'}; // Example headers

    // ✅ Log cURL for GET
    final curlCommand = [
      "curl -X GET '${uri.toString()}'",
      ...headers.entries.map((e) => "  -H '${e.key}: ${e.value}'"),
    ].join(" \\\n");
    // AppLogger.info("📤 cURL GET Request:\n$curlCommand", tag: AppLogger.api);
    print("📤 cURL GET Request:\n$curlCommand"); // Using print if AppLogger is not available

    final response = await http.get(uri, headers: headers).timeout(timeout);

    // ✅ Log HTTP Response
    // AppLogger.info("📥 Response Status: ${response.statusCode}", tag: AppLogger.api);
    // AppLogger.info("📥 Response Body:\n${response.body}", tag: AppLogger.api);
    print("📥 Response Status: ${response.statusCode}");
    print("📥 Response Body:\n${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isEmpty
          ? {}
          : json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> postJson(
      String path, Map<String, dynamic> body) async {
    final uri = _u(path);
    final headers = {'Content-Type': 'application/json'};

    // ✅ Log cURL for POST JSON
    final curlCommand = [
      "curl -X POST '${uri.toString()}'",
      "  -H 'Content-Type: application/json'",
      "  -d '${json.encode(body)}'",
    ].join(" \\\n");
    // AppLogger.info("📤 cURL POST JSON Request:\n$curlCommand", tag: AppLogger.api);
    print("📤 cURL POST JSON Request:\n$curlCommand");

    final response = await http
        .post(uri,
        headers: headers,
        body: json.encode(body))
        .timeout(timeout);

    // ✅ Log HTTP Response
    // AppLogger.info("📥 Response Status: ${response.statusCode}", tag: AppLogger.api);
    // AppLogger.info("📥 Response Body:\n${response.body}", tag: AppLogger.api);
    print("📥 Response Status: ${response.statusCode}");
    print("📥 Response Body:\n${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isEmpty
          ? {}
          : json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> postForm(
      String path, Map<String, dynamic> body) async {
    final uri = _u(path);

    final fieldsList = body.entries.map((e) => "  -F '${e.key}=${e.value}'").join(" \\\n");
    final curlCommand = [
      "curl -X POST '${uri.toString()}'",
      if (fieldsList.isNotEmpty) fieldsList,
    ].join(" \\\n");
    AppLogger.info("📤 cURL POST Form Request:\n$curlCommand", tag: AppLogger.api);

    final response = await http.post(uri, body: body).timeout(timeout);

    // ✅ Log HTTP Response
    AppLogger.info("📥 Response Status: ${response.statusCode}", tag: AppLogger.api);
    AppLogger.info("📥 Response Body:\n${response.body}", tag: AppLogger.api);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        print("Response body is empty, returning empty map.");
        return {}; // Return empty map if body is empty
      }

      try {
        // Decode JSON first, result is dynamic
        final decodedJson = json.decode(response.body);
        if (decodedJson is Map<String, dynamic>) {
          print("Successfully decoded and validated JSON as Map<String, dynamic>.");
          return decodedJson; // Return the correctly typed map
        } else {
          print("Decoded JSON is not a Map<String, dynamic>. Type: ${decodedJson.runtimeType}");
          throw FormatException('Expected a JSON object in response body, but got ${decodedJson.runtimeType}. Body: ${response.body}');
        }
      } catch (e, stackTrace) {
        print("Error parsing JSON response: $e\nStack Trace: $stackTrace");
        rethrow; // Re-throw the parsing error or a more specific one
      }
    } else {
      print("HTTP request failed with status ${response.statusCode}. Body: ${response.body}");
      throw Exception('POST $path failed: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> postBodyJson(
      String path,
      Map<String, dynamic> body,
      ) async {
    final uri = _u(path);

    AppLogger.info(
      "📤 JSON POST Request: $uri\nBody: ${jsonEncode(body)}",
      tag: AppLogger.api,
    );

    final response = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    )
        .timeout(timeout);

    AppLogger.info("📥 Response Status: ${response.statusCode}", tag: AppLogger.api);
    AppLogger.info("📥 Response Body:\n${response.body}", tag: AppLogger.api);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('POST $path failed: ${response.statusCode} ${response.body}');
    }
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
      allFields['tenant_id'] = tid.toString();
    }

    // cURL for multipart file upload is complex to reconstruct accurately with -F,
    // especially for binary data like file contents. Logging the intent is often more practical.
    final fieldParts = allFields.entries.map((e) => "  -F '${e.key}=${e.value}'").join(" \\\n");
    final curlCommand = [
      "curl -X POST '${_u(path)}'",
      "  -F 'file=@$filename (binary data)'", // Simplified representation for file
      if (allFields.isNotEmpty) fieldParts,
    ].join(" \\\n");
    // AppLogger.info("📤 cURL Upload CSV Request:\n$curlCommand", tag: AppLogger.api);
    print("📤 cURL Upload CSV Request:\n$curlCommand");

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

    // Log the response status and body for the multipart upload
    // AppLogger.info("📥 Upload Response Status: ${res.statusCode}", tag: AppLogger.api);
    // AppLogger.info("📥 Upload Response Body:\n${res.body}", tag: AppLogger.api);
    print("📥 Upload Response Status: ${res.statusCode}");
    print("📥 Upload Response Body:\n${res.body}");

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty
          ? {}
          : json.decode(res.body) as Map<String, dynamic>;
    }

    throw Exception(
      'CSV upload failed: ${res.statusCode} - ${res.reasonPhrase}\n${res.body}',
    );
  }




  Future<Uint8List> downloadCsvTemplate() async {
    final url = Uri.parse('$baseUrl/catalog/csv-template');
    final resp = await http.get(url, headers: {'Accept': 'text/csv'});
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return resp.bodyBytes;
    }
    throw Exception('Failed to download template: ${resp.statusCode}: ${resp.body}');
  }

  Future<Map<String, dynamic>> importCatalogFile({
    required String path,
    required String filename,
    required List<int> bytes,
  }) async {
    final uri = Uri.parse('$baseUrl/catalog/import');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    // add tenant_id if your backend still expects it from form
    final store = StoreUserData();
    final tenantId = await store.getTenantId();
    if (tenantId != null) req.fields['tenant_id'] = '$tenantId';
    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Import failed: ${resp.statusCode}: ${resp.body}');
  }

  Future<List<dynamic>> getCatalog({String? q}) async {
    final uri = Uri.parse('$baseUrl/catalog${q != null ? "?q=$q" : ""}');
    final resp = await http.get(uri, headers: {'Accept': 'application/json'});
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    throw Exception('Get catalog failed: ${resp.statusCode}: ${resp.body}');
  }

  Future<Map<String,dynamic>> createCatalogWithImage({
    required Map<String,String> fields,
    Uint8List? imageBytes,
    String? filename,
  }) async {
    final uri = Uri.parse('$baseUrl/catalog/with-image');
    final req = http.MultipartRequest('POST', uri);
    fields.forEach((k,v){ if (v.isNotEmpty) req.fields[k] = v; });
    if (imageBytes != null && filename != null) {
      req.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: filename));
    }
    final store = StoreUserData();
    final tenantId = await store.getTenantId();
    if (tenantId != null) req.fields['tenant_id'] = '$tenantId';
    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Create failed: ${resp.statusCode}: ${resp.body}');
  }

  Future<Map<String,dynamic>> updateCatalogItem(int id, Map<String,dynamic> body) async {
    final uri = Uri.parse('$baseUrl/catalog/$id');
    final resp = await http.put(uri, headers: {
      'Content-Type':'application/json',
      'Accept':'application/json'
    }, body: jsonEncode(body));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Update failed: ${resp.statusCode}: ${resp.body}');
  }

  Future<void> deleteCatalogItem(int id) async {
    final uri = Uri.parse('$baseUrl/catalog/$id');
    final resp = await http.delete(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Delete failed: ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<Map<String,dynamic>> bulkUpdate(List<int> ids, Map<String,dynamic> update) async {
    final uri = Uri.parse('$baseUrl/catalog/bulk-update');
    final resp = await http.post(uri, headers: {
      'Content-Type':'application/json',
      'Accept':'application/json'
    }, body: jsonEncode({'ids': ids, 'update': update}));
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Bulk update failed: ${resp.statusCode}: ${resp.body}');
  }
}
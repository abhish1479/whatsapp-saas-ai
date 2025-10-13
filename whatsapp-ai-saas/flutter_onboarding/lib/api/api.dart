import 'dart:convert';
import 'dart:typed_data';
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
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true'
    }; // Example headers

    // ✅ Log cURL for GET
    final curlCommand = [
      "curl -X GET '${uri.toString()}'",
      ...headers.entries.map((e) => "  -H '${e.key}: ${e.value}'"),
    ].join(" \\\n");
    // AppLogger.info("📤 cURL GET Request:\n$curlCommand", tag: AppLogger.api);
    print(
        "📤 cURL GET Request:\n$curlCommand"); // Using print if AppLogger is not available

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
    throw Exception(
        'GET $path failed: ${response.statusCode} ${response.body}');
  }

  Future<List<dynamic>> getJsonList(String path) async {
    final uri = _u(path);
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    print("📤 cURL GET Request:\n"
        "curl -X GET '${uri.toString()}' \\\n"
        "${headers.entries.map((e) => "-H '${e.key}: ${e.value}'").join(' \\\n')}");

    final response = await http.get(uri, headers: headers).timeout(timeout);

    print("📥 Response Status: ${response.statusCode}");
    print("📥 Response Body:\n${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded;
      } else {
        throw Exception('Expected JSON list but got ${decoded.runtimeType}');
      }
    }
    throw Exception(
        'GET $path failed: ${response.statusCode} ${response.body}');
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
        .post(uri, headers: headers, body: json.encode(body))
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
    throw Exception(
        'POST $path failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> postForm(
      String path, Map<String, dynamic> body) async {
    final uri = _u(path);

    final fieldsList =
        body.entries.map((e) => "  -F '${e.key}=${e.value}'").join(" \\\n");
    final curlCommand = [
      "curl -X POST '${uri.toString()}'",
      if (fieldsList.isNotEmpty) fieldsList,
    ].join(" \\\n");
    AppLogger.info("📤 cURL POST Form Request:\n$curlCommand",
        tag: AppLogger.api);

    final response = await http.post(uri, body: body).timeout(timeout);

    // ✅ Log HTTP Response
    AppLogger.info("📥 Response Status: ${response.statusCode}",
        tag: AppLogger.api);
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
          print(
              "Successfully decoded and validated JSON as Map<String, dynamic>.");
          return decodedJson; // Return the correctly typed map
        } else {
          print(
              "Decoded JSON is not a Map<String, dynamic>. Type: ${decodedJson.runtimeType}");
          throw FormatException(
              'Expected a JSON object in response body, but got ${decodedJson.runtimeType}. Body: ${response.body}');
        }
      } catch (e, stackTrace) {
        print("Error parsing JSON response: $e\nStack Trace: $stackTrace");
        rethrow; // Re-throw the parsing error or a more specific one
      }
    } else {
      print(
          "HTTP request failed with status ${response.statusCode}. Body: ${response.body}");
      throw Exception(
          'POST $path failed: ${response.statusCode} ${response.body}');
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

    AppLogger.info("📥 Response Status: ${response.statusCode}",
        tag: AppLogger.api);
    AppLogger.info("📥 Response Body:\n${response.body}", tag: AppLogger.api);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'POST $path failed: ${response.statusCode} ${response.body}');
    }
  }

  /// CSV upload using multipart/form-data
  Future<Map<String, dynamic>> uploadCsv1(
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
    final fieldParts = allFields.entries
        .map((e) => "  -F '${e.key}=${e.value}'")
        .join(" \\\n");
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


  Future<List<dynamic>> getCatalog({
    required int tenantId,
    String? query,
    int limit = 200,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/catalog/get_catalog?tenant_id=$tenantId'
          '${query != null ? "&q=$query" : ""}'
          '&limit=$limit&offset=$offset',
    );

    final resp = await http.get(uri, headers: {'Accept': 'application/json','ngrok-skip-browser-warning': 'true',});
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('getCatalog failed: ${resp.body}');
  }

  Future<Uint8List> downloadCsvTemplate() async {
    final uri = Uri.parse('$baseUrl/catalog/csv-template');
    final resp = await http.get(uri, headers: {'Accept': 'text/csv'});
    if (resp.statusCode == 200) return resp.bodyBytes;
    throw Exception('Failed to download CSV: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> addCatalogItem(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/catalog/add');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Add failed: ${resp.body}');
  }

  Future<Map<String, dynamic>> addCatalog({
    required int tenantId,
    required String name,
    String? itemType,
    String? category,
    String? price,
    String? discount,
    String? description,
    String? imageUrl,
    String? sourceUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/catalog/add');
    final body = {
      'tenant_id': tenantId,
      'name': name,
      'item_type': itemType,
      'category': category,
      'price': price,
      'discount': discount,
      'description': description,
      'image_url': imageUrl,
      'source_url': sourceUrl,
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }
    throw Exception('Add failed: ${resp.body}');
  }

  Future<Map<String, dynamic>> addCatalogWithMedia({
    required int tenantId,
    required String itemType,
    required String name,
    String? description,
    String? category,
    String? price,
    String? discount,
    String? sourceUrl,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final uri = Uri.parse('$baseUrl/catalog/add_with_media');
    final req = http.MultipartRequest('POST', uri);

    req.fields['tenant_id'] = tenantId.toString();
    req.fields['item_type'] = itemType;
    req.fields['name'] = name;
    if (description != null) req.fields['description'] = description;
    if (category != null) req.fields['category'] = category;
    if (price != null) req.fields['price'] = price;
    if (discount != null) req.fields['discount'] = discount;
    if (sourceUrl != null) req.fields['source_url'] = sourceUrl;
    if (imageBytes != null && imageName != null) {
      req.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));
    }

    final resp = await http.Response.fromStream(await req.send());
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Add with media failed: ${resp.body}');
  }

  Future<Map<String, dynamic>> updateCatalogItem(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/catalog/update');
    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Update failed: ${resp.body}');
  }

  Future<void> deleteCatalogItem(int itemId) async {
    final uri = Uri.parse('$baseUrl/catalog/delete?item_id=$itemId');
    final resp = await http.delete(uri);
    if (resp.statusCode != 200) throw Exception('Delete failed: ${resp.body}');
  }

  Future<Map<String, dynamic>> bulkUpdate(Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/catalog/bulk-update');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('Bulk update failed: ${resp.body}');
  }

  Future<Map<String, dynamic>> uploadCsv({
    required int tenantId,
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$baseUrl/catalog/CSV_upload');
    final req = http.MultipartRequest('POST', uri);
    req.fields['tenant_id'] = tenantId.toString();
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final resp = await http.Response.fromStream(await req.send());
    if (resp.statusCode == 200) return jsonDecode(resp.body);
    throw Exception('CSV upload failed: ${resp.body}');
  }

  Future<String> uploadImage(Uint8List bytes, String filename) async {
    final uri = Uri.parse('$baseUrl/catalog/image_upload');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(http.MultipartFile.fromBytes('payload', bytes, filename: filename));

    final resp = await http.Response.fromStream(await req.send());
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['image_url'];
    }
    throw Exception('Image upload failed: ${resp.body}');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  final String baseUrl;
  Api(this.baseUrl);

  Future<Map<String, dynamic>> postForm(String path, Map<String, String> body) async {
    final res = await http.post(Uri.parse('$baseUrl$path'), body: body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body.isEmpty ? '{}' : res.body);
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> uploadCsv(String path, String tenantId, List<int> bytes, {String filename = "items.csv"}) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    req.fields['tenant_id'] = tenantId;
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body.isEmpty ? '{}' : res.body);
    }
    throw Exception('Upload failed: ${res.statusCode} ${res.body}');
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart'; // Import for MediaType
import 'package:humainity_flutter/models/knowledge_source.dart';

class KnowledgeRepository {
  final http.Client _client;
  final String? _baseUrl = dotenv.env['API_BASE_URL'];

  KnowledgeRepository(this._client);

  Future<List<KnowledgeSource>> getKnowledgeSources(String tenantId) async {
    final uri = Uri.parse('$_baseUrl/knowledge/get_knowledge_sources?tenant_id=$tenantId');
    try {
      final response = await _client.get(uri, headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          return data.map((json) => KnowledgeSource.fromJson(json)).toList();
        } else {
          throw Exception(body['error'] ?? 'Failed to parse knowledge sources');
        }
      } else {
        throw Exception('Failed to fetch knowledge sources: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getKnowledgeSources: $e');
      rethrow;
    }
  }

  Future<KnowledgeSource> uploadFile(String tenantId, PlatformFile file) async {
    final uri = Uri.parse('$_baseUrl/knowledge/upload_file');
    try {
      var request = http.MultipartRequest('POST', uri)
        ..fields['tenant_id'] = tenantId
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
            contentType: MediaType('application', 'octet-stream'), // Use generic type or detect
          ),
        );

      request.headers['accept'] = 'application/json';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return KnowledgeSource.fromJson(body['data']);
        } else {
          throw Exception(body['error'] ?? 'Failed to parse file upload response');
        }
      } else {
        throw Exception('Failed to upload file: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in uploadFile: $e');
      rethrow;
    }
  }

  Future<KnowledgeSource> webCrawl(String tenantId, String url) async {
    final uri = Uri.parse('$_baseUrl/knowledge/web_crawl');
    // Extract a name from the URL, e.g., "example.com"
    final String name = Uri.parse(url).host;

    try {
      final response = await _client.post(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'tenant_id': int.tryParse(tenantId) ?? 1, // API expects integer
          'url': url,
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        // Assuming the web_crawl response is similar to get_knowledge_sources
        // Based on your API doc, it's not clear what it returns.
        // Let's assume it returns the new KnowledgeSource object.
        if (body['success'] == true && body['data'] != null) {
          return KnowledgeSource.fromJson(body['data']);
        } else if (body['success'] == true) {
          // If it doesn't return the object, we'll have to manually create a temporary one
          // or just trigger a refresh. Let's assume it returns the object for now.
          throw Exception('Web crawl API did not return expected data.');
        }
        else {
          throw Exception(body['error'] ?? 'Failed to add URL');
        }
      } else {
        throw Exception('Failed to add URL: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in webCrawl: $e');
      rethrow;
    }
  }

  Future<String> queryRAG(String tenantId, String query) async {
    final uri = Uri.parse(
        '$_baseUrl/rag/rag_test_query?tenant_id=$tenantId&q=${Uri.encodeComponent(query)}&n=3');
    try {
      final response = await _client.post(uri, headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        // The API response for RAG isn't specified, so we'll assume
        // it's a simple text response or a JSON object.
        // Let's check for a 'data' field, otherwise return the whole body.
        if (body['success'] == true && body['data'] != null) {
           return body['data'].toString();
        } else if (body['success'] == true) {
          // If it doesn't return the object, we'll have to manually create a temporary one
          // or just trigger a refresh. Let's assume it returns the object for now.
          throw Exception('NO Data Found in Knowledge Base.');
        }
        else {
          throw Exception(body['error'] ?? 'Failed to fetch data');
        }
      }
      else {
         throw Exception('Failed to fetch data: ${response.body}');
      }
    }catch (e) {
      debugPrint('Error in queryRAG: $e');
      rethrow;
    }
  }
}

// Provider for the HTTP client
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// Provider for the KnowledgeRepository
final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  return KnowledgeRepository(client);
});
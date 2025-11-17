import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:http/http.dart' as http;
import 'package:humainity_flutter/models/template.dart';
// Remove TenantService import

class TemplatesRepository {
  final http.Client _client;
  // Get base URL from environment
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // Remove TenantService from constructor
  TemplatesRepository(this._client);

  // FETCH ALL
  // Pass tenantId as a parameter
  Future<List<Template>> getTemplates(String tenantId) async {
    final uri = Uri.parse('$_baseUrl/templates/get_templates_list?tenant_id=$tenantId');

    try {
      final response = await _client.get(uri, headers: {'accept': 'application/json'});

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          return data.map((json) => Template.fromJson(json)).toList();
        } else {
          throw Exception(body['error'] ?? 'Failed to parse templates');
        }
      } else {
        throw Exception('Failed to fetch templates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTemplates: $e');
      rethrow;
    }
  }

  // CREATE
  // Pass tenantId as a parameter
  Future<Template> createTemplate(String tenantId, Map<String, dynamic> templateData) async {
    final uri = Uri.parse('$_baseUrl/templates/create');

    final body = json.encode({
      ...templateData,
      'tenant_id': int.tryParse(tenantId) ?? 1, // Use passed tenantId
    });

    try {
      final response = await _client.post(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == true) {
        return Template.fromJson(responseBody['data']);
      } else {
        throw Exception(responseBody['error']?['details']?.join(', ') ?? 'Failed to create template');
      }
    } catch (e) {
      print('Error in createTemplate: $e');
      rethrow;
    }
  }

  // UPDATE
  Future<Template> updateTemplate(int templateId, Map<String, dynamic> templateData) async {
    final uri = Uri.parse('$_baseUrl/templates/update?template_id=$templateId');

    try {
      final response = await _client.put(
        uri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(templateData), // Send only fields to update
      );

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == true) {
        return Template.fromJson(responseBody['data']);
      } else {
        throw Exception(responseBody['error']?['details']?.join(', ') ?? 'Failed to update template');
      }
    } catch (e) {
      print('Error in updateTemplate: $e');
      rethrow;
    }
  }

  // DELETE
  Future<void> deleteTemplate(int templateId) async {
    final uri = Uri.parse('$_baseUrl/templates/delete?template_id=$templateId');

    try {
      final response = await _client.delete(
        uri,
        headers: {'accept': 'application/json'},
      );

      final responseBody = json.decode(response.body);
      if (response.statusCode != 200 || responseBody['success'] != true) {
        // Handle restricted delete
        if (responseBody['error']?['code'] == 'DELETE_RESTRICTED') {
          throw Exception(responseBody['message'] ?? 'Cannot delete activated template');
        }
        throw Exception(responseBody['error']?['details']?.join(', ') ?? 'Failed to delete template');
      }
      // Success, no data returned
    } catch (e) {
      print('Error in deleteTemplate: $e');
      rethrow;
    }
  }
}

// Keep existing providers
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  // Remove TenantService dependency
  return TemplatesRepository(client);
});
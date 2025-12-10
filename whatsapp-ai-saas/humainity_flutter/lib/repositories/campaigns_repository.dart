import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:humainity_flutter/models/campaign.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CampaignsRepository {
  // Ensure your .env has the correct API_BASE_URL (e.g. http://127.0.0.1:8000)
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  final String _authToken;
  final int _tenantId;

  CampaignsRepository({required String token, required int tenantId})
      : _authToken = token, _tenantId = tenantId;

  Future<List<Campaign>> fetchCampaigns() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/campaigns/list?tenant_id=$_tenantId'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Campaign.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load campaigns: ${response.body}');
    }
  }

  Future<Campaign> fetchCampaignDetails(int campaignId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/campaigns/get_campaign?campaign_id=$campaignId'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Campaign.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load campaign details');
    }
  }

  Future<void> createCampaign({
    required String name,
    required String? description,
    required String channel,
    required int? templateId,
    required bool runImmediate,
    required PlatformFile file,
  }) async {
    // FIX: 'name' is required by the server as a Query Parameter, not a Form Field.
    // We append it to the URL.
    final uri = Uri.parse('$_baseUrl/campaigns/create').replace(
      queryParameters: {'name': name},
    );

    var request = http.MultipartRequest('POST', uri);

    // Add Headers
    request.headers['Authorization'] = 'Bearer $_authToken';

    // Add Form Fields
    if (description != null) request.fields['description'] = description;
    request.fields['channel'] = channel;
    if (templateId != null) request.fields['template_id'] = templateId.toString();
    request.fields['run_immediate'] = runImmediate.toString();
    request.fields['tenant_id'] = _tenantId.toString();

    // Add CSV File
    if (file.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ));
    } else if (file.path != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path!,
      ));
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      final respStr = await response.stream.bytesToString();
      throw Exception('Failed to create campaign: $respStr');
    }
  }

  Future<void> updateStatus(int campaignId, String action) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/campaigns/update_status?campaign_id=$campaignId'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'action': action}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }
}
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';
import 'package:humainity_flutter/models/business_profile.dart';

final businessProfileRepositoryProvider = Provider<BusinessProfileRepository>((ref) {
  final storeUserData = ref.watch(storeUserDataProvider);
  return BusinessProfileRepository(storeUserData);
});

class BusinessProfileRepository {
  final StoreUserData? _store;

  BusinessProfileRepository(this._store);

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

  Future<BusinessProfile> createBusinessProfile(BusinessProfileCreate payload) async {
    final url = Uri.parse('$_baseUrl/business_profile/create');
    final headers = await _getHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode == 201) {
      return BusinessProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create profile: ${response.body}');
    }
  }

  Future<BusinessProfile?> getBusinessProfile(int tenantId) async {
    final url = Uri.parse('$_baseUrl/business_profile/get?tenant_id=$tenantId');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return BusinessProfile.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch profile: ${response.body}');
    }
  }

  Future<BusinessProfile> updateBusinessProfile(BusinessProfileUpdate payload) async {
    final url = Uri.parse('$_baseUrl/business_profile/update');
    final headers = await _getHeaders();

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(payload.toJson()),
    );

    if (response.statusCode == 200) {
      return BusinessProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }
}
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/subscription_plan.dart';

class PlansRepository {
  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) throw Exception('Missing API_BASE_URL in .env');
    return url;
  }

  Future<List<SubscriptionPlan>> fetchPlans() async {
    final url = Uri.parse('$_baseUrl/subscriptions/get_all_plans');

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      return data.map((e) => SubscriptionPlan.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load plans (${res.statusCode})');
    }
  }
}

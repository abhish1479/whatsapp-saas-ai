import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainity_flutter/core/utils/api_client.dart';
import 'package:humainity_flutter/core/storage/store_user_data.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final store = ref.watch(storeUserDataProvider);
  return ApiClient(store);
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:humainise_ai/core/utils/api_client.dart';
import 'package:humainise_ai/core/storage/store_user_data.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final store = ref.watch(storeUserDataProvider);
  return ApiClient(store);
});

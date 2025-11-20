import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/subscription_plan.dart';
import '../../repositories/plans_repository.dart';

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository();
});

final plansProvider =
    FutureProvider.autoDispose<List<SubscriptionPlan>>((ref) async {
  final repo = ref.watch(plansRepositoryProvider);
  return repo.fetchPlans();
});

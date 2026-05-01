import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_mobil_bayeur/models/delegation_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';
import 'package:app_mobil_bayeur/services/delegation_service.dart';

final delegationServiceProvider = Provider<DelegationService>((ref) {
  final apiService = ApiService();
  return DelegationService(apiService);
});

final myDelegationsProvider = FutureProvider<List<Delegation>>((ref) async {
  return ref.watch(delegationServiceProvider).getMyDelegations();
});

final assignedDelegationsProvider = FutureProvider<List<Delegation>>((ref) async {
  return ref.watch(delegationServiceProvider).getAssignedDelegations();
});

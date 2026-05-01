import 'package:app_mobil_bayeur/models/delegation_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class DelegationService {
  final ApiService _apiService;

  DelegationService(this._apiService);

  Future<List<Delegation>> getMyDelegations() async {
    try {
      final response = await _apiService.dio.get('/delegations/mine');
      return (response.data as List).map((json) => Delegation.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Delegation>> getAssignedDelegations() async {
    try {
      final response = await _apiService.dio.get('/delegations/assigned');
      return (response.data as List).map((json) => Delegation.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Delegation> createInvitation(String delegateEmail, List<String> permissions) async {
    try {
      final response = await _apiService.dio.post('/delegations', data: {
        'delegate_email': delegateEmail,
        'permissions': permissions,
      });
      return Delegation.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> revokeDelegation(String id) async {
    try {
      await _apiService.dio.delete('/delegations/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<Delegation> acceptInvitation(String code) async {
    try {
      final response = await _apiService.dio.post('/delegations/accept', data: {'code': code});
      return Delegation.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

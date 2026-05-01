import 'package:app_mobil_bayeur/models/lease_contract_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class LeaseService {
  final ApiService _api;

  LeaseService(this._api);

  Future<LeaseContract> createLeaseRequest(Map<String, dynamic> data) async {
    final response = await _api.post('/api/leases', data: data);
    return LeaseContract.fromJson(response.data);
  }

  Future<List<LeaseContract>> getMyLeases() async {
    final response = await _api.get('/api/leases/my');
    return (response.data as List).map((l) => LeaseContract.fromJson(l)).toList();
  }

  Future<LeaseContract> getLeaseById(String id) async {
    final response = await _api.get('/api/leases/$id');
    return LeaseContract.fromJson(response.data);
  }

  Future<LeaseContract> signLease(String leaseId, String role, String signature) async {
    final response = await _api.post('/api/leases/$leaseId/sign', data: {
      'role': role,
      'signature': signature,
    });
    return LeaseContract.fromJson(response.data);
  }

  Future<LeaseContract> terminateLease(String leaseId) async {
    final response = await _api.post('/api/leases/$leaseId/terminate');
    return LeaseContract.fromJson(response.data);
  }
}

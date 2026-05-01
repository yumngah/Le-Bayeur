import 'package:app_mobil_bayeur/models/maintenance_model.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class MaintenanceService {
  final ApiService _apiService;

  MaintenanceService(this._apiService);

  // --- Maintenance Requests ---
  
  Future<List<MaintenanceRequest>> getPropertyMaintenanceRequests(String propertyId) async {
    final response = await _apiService.get('/maintenance/property/$propertyId');
    return (response.data as List).map((json) => MaintenanceRequest.fromJson(json)).toList();
  }

  Future<MaintenanceRequest> createMaintenanceRequest(Map<String, dynamic> data) async {
    final response = await _apiService.post('/maintenance/requests', data: data);
    return MaintenanceRequest.fromJson(response.data);
  }

  Future<void> assignTechnician(String requestId, String technicianId) async {
    await _apiService.post('/maintenance/requests/$requestId/assign', data: {
      'technician_id': technicianId,
    });
  }

  Future<void> updateRequestStatus(String requestId, RequestStatus status) async {
    await _apiService.post('/maintenance/requests/$requestId/status', data: {
      'status': status.name,
    });
  }

  // --- Intervention Reports ---

  Future<void> submitInterventionReport(String maintenanceId, Map<String, dynamic> reportData) async {
    await _apiService.post('/maintenance/$maintenanceId/report', data: reportData);
  }

  Future<InterventionReport?> getInterventionReport(String maintenanceId) async {
    try {
      final response = await _apiService.get('/maintenance/$maintenanceId/report');
      return InterventionReport.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // --- Technician Management ---

  Future<List<Technician>> searchTechnicians({MaintenanceType? specialty, bool availableOnly = false}) async {
    final response = await _apiService.get('/maintenance/technicians/search', params: {
      'specialty': specialty?.name,
      'available': availableOnly,
    });
    return (response.data as List).map((json) => Technician.fromJson(json)).toList();
  }

  Future<void> inviteTechnician(String propertyId, String technicianId) async {
    await _apiService.post('/maintenance/properties/$propertyId/invite-technician', data: {
      'technician_id': technicianId,
    });
  }

  Future<void> registerAsTechnician(Map<String, dynamic> registrationData) async {
    await _apiService.post('/maintenance/technicians/register', data: registrationData);
  }

  // --- Evaluations ---

  Future<void> submitEvaluation(String targetUserId, int rating, String? comment, String role) async {
    await _apiService.post('/maintenance/evaluations', data: {
      'target_id': targetUserId,
      'rating': rating,
      'comment': comment,
      'reviewer_role': role,
    });
  }
}

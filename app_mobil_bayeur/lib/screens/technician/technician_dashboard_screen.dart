import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/maintenance_model.dart';
import 'package:app_mobil_bayeur/services/maintenance_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';
import 'package:app_mobil_bayeur/screens/maintenance/maintenance_report_screen.dart';

class TechnicianDashboardScreen extends ConsumerStatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  ConsumerState<TechnicianDashboardScreen> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends ConsumerState<TechnicianDashboardScreen> {
  late MaintenanceService _maintenanceService;
  List<MaintenanceRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _maintenanceService = MaintenanceService(ApiService());
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      // In a real app, this would get only requests assigned to the tech
      final rs = await _maintenanceService.getPropertyMaintenanceRequests('all'); 
      setState(() {
        _requests = rs.where((r) => r.status != RequestStatus.COMPLETED).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement dashboard tech: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Tableau de bord Pro", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadDashboard,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildHeaderStats(),
                const SizedBox(height: 32),
                Text("Interventions en cours", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (_requests.isEmpty)
                  _buildEmptyState()
                else
                  ..._requests.map((r) => _buildRequestCard(r)),
              ],
            ),
          ),
    );
  }

  Widget _buildHeaderStats() {
    return Row(
      children: [
        _buildStatCard("Missions", _requests.length.toString(), Colors.blue),
        const SizedBox(width: 16),
        _buildStatCard("Note", "4.8/5", Colors.orange), // Simulated
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(MaintenanceRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Text(request.type.name, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                Text(request.urgency.name, style: TextStyle(color: request.urgency == Urgency.URGENT ? Colors.red : Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 12),
            Text(request.propertyName ?? "Bien Immobilier", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(request.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text("Douala, Akwa", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaintenanceReportScreen(requestId: request.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text("Rédiger Rapport", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Aucune mission en cours", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

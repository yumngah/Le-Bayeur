import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/maintenance_model.dart';
import 'package:app_mobil_bayeur/services/maintenance_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';


class MaintenancePlanningScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const MaintenancePlanningScreen({super.key, required this.propertyId});

  @override
  ConsumerState<MaintenancePlanningScreen> createState() => _MaintenancePlanningScreenState();
}

class _MaintenancePlanningScreenState extends ConsumerState<MaintenancePlanningScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MaintenanceService _maintenanceService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _maintenanceService = MaintenanceService(ApiService());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Maintenance", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[700],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue[700],
          tabs: [
            const Tab(text: "Demandes"),
            const Tab(text: "Planification"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildSchedulesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanMaintenanceDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return FutureBuilder<List<MaintenanceRequest>>(
      future: _maintenanceService.getPropertyMaintenanceRequests(widget.propertyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Erreur: ${snapshot.error}"));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aucune demande de maintenance"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final req = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getUrgencyColor(req.urgency).withValues(alpha: 0.1),
                  child: Icon(_getTypeIcon(req.type), color: _getUrgencyColor(req.urgency)),
                ),
                title: Text(req.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text("Urgence: ${req.urgency.name}"),
                trailing: Chip(
                  label: Text(req.status.name, style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: _getStatusColor(req.status),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSchedulesTab() {
    return const Center(child: Text("Gestion des maintenances périodiques à venir..."));
  }

  void _showPlanMaintenanceDialog() {
    // Basic dialog to simulate planning
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Planifier une maintenance"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: "Description")),
            SizedBox(height: 12),
            // Frequency selection, date picker, etc.
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Planifier")),
        ],
      ),
    );
  }

  Color _getUrgencyColor(Urgency urgency) {
    return urgency == Urgency.URGENT ? Colors.red : Colors.orange;
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.PENDING: return Colors.blue;
      case RequestStatus.IN_PROGRESS: return Colors.orange;
      case RequestStatus.COMPLETED: return Colors.green;
      case RequestStatus.REJECTED: return Colors.red;
    }
  }

  IconData _getTypeIcon(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.ELECTRICITY: return Icons.electric_bolt;
      case MaintenanceType.PLUMBING: return Icons.water_drop;
      case MaintenanceType.GENERAL: return Icons.home_repair_service;
    }
  }
}

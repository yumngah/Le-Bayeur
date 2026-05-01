import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/maintenance_model.dart';
import 'package:app_mobil_bayeur/services/maintenance_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class TechnicianSearchScreen extends ConsumerStatefulWidget {
  final String? propertyId;

  const TechnicianSearchScreen({super.key, this.propertyId});

  @override
  ConsumerState<TechnicianSearchScreen> createState() => _TechnicianSearchState();
}

class _TechnicianSearchState extends ConsumerState<TechnicianSearchScreen> {
  late MaintenanceService _maintenanceService;
  List<Technician> _technicians = [];
  bool _isLoading = true;
  MaintenanceType? _specialtyFilter;

  @override
  void initState() {
    super.initState();
    _maintenanceService = MaintenanceService(ApiService());
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    try {
      final techs = await _maintenanceService.searchTechnicians(specialty: _specialtyFilter);
      setState(() {
        _technicians = techs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur recherche techniciens: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Trouver un Pro", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _technicians.length,
                    itemBuilder: (context, index) => _buildTechnicianCard(_technicians[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text("Tous"),
            selected: _specialtyFilter == null,
            onSelected: (_) => setState(() { _specialtyFilter = null; _loadTechnicians(); }),
            backgroundColor: Colors.grey[100],
            selectedColor: Colors.blue[100],
          ),
          const SizedBox(width: 8),
          ...MaintenanceType.values.map((type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type.name),
              selected: _specialtyFilter == type,
              onSelected: (_) => setState(() { _specialtyFilter = type; _loadTechnicians(); }),
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.blue[100],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(Technician tech) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blue[100],
                  child: Text(tech.name?.substring(0, 1).toUpperCase() ?? "P", style: TextStyle(fontSize: 24, color: Colors.blue[900], fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(tech.name ?? "N/A", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
                          if (tech.isVerified) const Icon(Icons.verified, color: Colors.blue, size: 18),
                        ],
                      ),
                      Text("${tech.specialty.name} • ${tech.yearsExperience} ans d'exp", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(" ${tech.averageRating.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text(" (12 avis)", style: TextStyle(color: Colors.grey)), // Simulated count
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(tech.location ?? "Non spécifié", style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _inviteTech(tech),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Inviter au bien"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _inviteTech(Technician tech) async {
    if (widget.propertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aucun bien immobilier sélectionné.")));
      return;
    }

    try {
      await _maintenanceService.inviteTechnician(widget.propertyId!, tech.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invitation envoyée à ${tech.name}")));
      }
    } catch (e) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur d'invitation: $e")));
    }
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/maintenance_model.dart';
import 'package:app_mobil_bayeur/services/maintenance_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class TechnicianRegistrationScreen extends ConsumerStatefulWidget {
  const TechnicianRegistrationScreen({super.key});

  @override
  ConsumerState<TechnicianRegistrationScreen> createState() => _TechnicianRegistrationState();
}

class _TechnicianRegistrationState extends ConsumerState<TechnicianRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  MaintenanceType _selectedSpecialty = MaintenanceType.ELECTRICITY;
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSubmitting = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final maintenanceService = MaintenanceService(ApiService());
      await maintenanceService.registerAsTechnician({
        'specialty': _selectedSpecialty.name,
        'years_experience': int.parse(_experienceController.text),
        'bio': _bioController.text,
        'location': _locationController.text,
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            content: const Text(
              "Candidature envoyée ! Votre profil sera vérifié par notre équipe avant de pouvoir accepter des missions.",
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text("Retour à l'accueil"),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur d'inscription: $e")));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Devenir Technicien", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Inscrivez-vous en tant que professionnel pour proposer vos services aux propriétaires.",
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 32),
              
              const Text("Votre Spécialité", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<MaintenanceType>(
                value: _selectedSpecialty,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: MaintenanceType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedSpecialty = val!),
              ),
              const SizedBox(height: 24),
              
              const Text("Années d'expérience", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Nombre d'années",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => (val?.isEmpty ?? true) ? "Requis" : null,
              ),
              const SizedBox(height: 24),
              
              const Text("Lieu d'activité", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: "Ex: Douala, Akwa",
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => (val?.isEmpty ?? true) ? "Requis" : null,
              ),
              const SizedBox(height: 24),
              
              const Text("Dites-en plus sur vous (Bio)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Décrivez vos compétences et expériences...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => (val?.isEmpty ?? true) ? "Requis" : null,
              ),
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Candidater maintenant", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

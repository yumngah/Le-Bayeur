// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_mobil_bayeur/models/maintenance_model.dart';
import 'package:app_mobil_bayeur/services/maintenance_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class MaintenanceRequestScreen extends StatefulWidget {
  final String propertyId;

  const MaintenanceRequestScreen({super.key, required this.propertyId});

  @override
  State<MaintenanceRequestScreen> createState() => _MaintenanceRequestState();
}

class _MaintenanceRequestState extends State<MaintenanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  MaintenanceType _selectedType = MaintenanceType.PLUMBING;
  Urgency _selectedUrgency = Urgency.NORMAL;
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  void _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() => _images.addAll(selectedImages));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    try {
      final maintenanceService = MaintenanceService(ApiService());
      await maintenanceService.createMaintenanceRequest({
        'property_id': widget.propertyId,
        'type': _selectedType.name,
        'description': _descriptionController.text,
        'urgency': _selectedUrgency.name,
        // photo URLs would be uploaded to storage first in a real app
        'photos': [], 
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            content: const Text(
              "Demande envoyée ! Le propriétaire et le technicien associé ont été notifiés.",
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur d'envoi: $e")));
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
        title: Text("Signaler un problème", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
                "Décrivez le problème rencontré pour une intervention rapide.",
                style: TextStyle(color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 32),
              
              const Text("Type de problème", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: MaintenanceType.values.map((type) => ChoiceChip(
                  label: Text(type.name),
                  selected: _selectedType == type,
                  onSelected: (_) => setState(() => _selectedType = type),
                  selectedColor: Colors.blue[100],
                  labelStyle: TextStyle(color: _selectedType == type ? Colors.blue[900] : Colors.black),
                )).toList(),
              ),
              const SizedBox(height: 24),

              const Text("Urgence", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<Urgency>(
                      title: const Text("Normal", style: TextStyle(fontSize: 14)),
                      value: Urgency.NORMAL,
                      groupValue: _selectedUrgency,
                      onChanged: (val) => setState(() => _selectedUrgency = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<Urgency>(
                      title: const Text("Urgent", style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold)),
                      value: Urgency.URGENT,
                      groupValue: _selectedUrgency,
                      onChanged: (val) => setState(() => _selectedUrgency = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text("Description détaillée", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Ex: Fuite d'eau sous l'évier de la cuisine...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => (val?.isEmpty ?? true) ? "Requis" : null,
              ),
              const SizedBox(height: 24),
              
              const Text("Photos / Vidéos", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildImagePicker(),
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
                    : const Text("Envoyer la demande", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        if (_images.isEmpty)
          InkWell(
            onTap: _pickImages,
            child: Container(
              height: 150,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!, style: BorderStyle.none)),
              child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey), SizedBox(height: 8), Text("Ajouter des photos", style: TextStyle(color: Colors.grey))])),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return IconButton(onPressed: _pickImages, icon: const Icon(Icons.add_a_photo_outlined));
                }
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 100,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: AssetImage(_images[index].path), fit: BoxFit.cover)),
                );
              },
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_mobil_bayeur/models/maintenance_model.dart';
import 'package:app_mobil_bayeur/services/maintenance_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class MaintenanceReportScreen extends StatefulWidget {
  final String requestId;

  const MaintenanceReportScreen({super.key, required this.requestId});

  @override
  State<MaintenanceReportScreen> createState() => _MaintenanceReportState();
}

class _MaintenanceReportState extends State<MaintenanceReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final List<XFile> _beforePhotos = [];
  final List<XFile> _afterPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  void _pickImages(bool isBefore) async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        if (isBefore) {
          _beforePhotos.addAll(selectedImages);
        } else {
          _afterPhotos.addAll(selectedImages);
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    try {
      final maintenanceService = MaintenanceService(ApiService());
      await maintenanceService.submitInterventionReport(widget.requestId, {
        'description': _descriptionController.text,
        'cost': double.parse(_costController.text),
        'recommendations': _recommendationsController.text,
        'before_photos': [], // Placeholder for URLs
        'after_photos': [], // Placeholder for URLs
      });

      // Update request status to COMPLETED
      await maintenanceService.updateRequestStatus(widget.requestId, RequestStatus.COMPLETED);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            content: const Text(
              "Rapport soumis avec succès ! L'intervention est marquée comme terminée.",
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text("Fermer"),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur de soumission: $e")));
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
        title: Text("Rapport d'intervention", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
              const Text("Description de l'intervention", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Qu'avez-vous fait ? Réparations effectuées...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => (val?.isEmpty ?? true) ? "Requis" : null,
              ),
              const SizedBox(height: 24),
              
              const Text("Coût réel (FCFA)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Montant total des travaux",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: (val) => (val?.isEmpty ?? true) ? "Requis" : null,
              ),
              const SizedBox(height: 24),

              const Text("Photos AVANT", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildImagePicker(true),
              const SizedBox(height: 24),

              const Text("Photos APRÈS", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildImagePicker(false),
              const SizedBox(height: 24),
              
              const Text("Recommandations", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _recommendationsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Conseils pour éviter le problème à l'avenir...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
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
                    : const Text("Soumettre le rapport", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isBefore) {
    final images = isBefore ? _beforePhotos : _afterPhotos;
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + 1,
        itemBuilder: (context, index) {
          if (index == images.length) {
            return IconButton(onPressed: () => _pickImages(isBefore), icon: const Icon(Icons.add_a_photo_outlined, color: Colors.blue));
          }
          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: AssetImage(images[index].path), fit: BoxFit.cover)),
          );
        },
      ),
    );
  }
}

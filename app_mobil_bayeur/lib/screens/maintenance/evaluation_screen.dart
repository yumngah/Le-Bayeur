import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/widgets/rating_widget.dart';
import 'package:app_mobil_bayeur/services/maintenance_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class EvaluationScreen extends StatefulWidget {
  final String technicianId;
  final String technicianName;
  final String requestId;
  final String role; // LANDLORD or TENANT

  const EvaluationScreen({
    super.key,
    required this.technicianId,
    required this.technicianName,
    required this.requestId,
    required this.role,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  void _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez sélectionner une note")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final maintenanceService = MaintenanceService(ApiService());
      await maintenanceService.submitEvaluation(
        widget.technicianId,
        _rating,
        _commentController.text,
        widget.role,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            content: const Text(
              "Merci pour votre évaluation ! Cela aide la communauté à choisir les meilleurs professionnels.",
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
        title: Text("Évaluer le Pro", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(widget.technicianName, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("Technicien Professionnel", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 48),
            
            const Text("Quelle est la qualité globale de l'intervention ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            RatingWidget(onRatingChanged: (rating) => setState(() => _rating = rating)),
            
            const SizedBox(height: 48),
            const Align(alignment: Alignment.centerLeft, child: Text("Commentaire (optionnel)", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Dites-nous ce qui s'est bien passé ou ce qui pourrait être amélioré...",
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
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Envoyer mon avis", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/lease_contract_model.dart';
import 'package:app_mobil_bayeur/widgets/contract_viewer.dart';
import 'package:app_mobil_bayeur/screens/lease/lease_signature_screen.dart';

class LeaseContractScreen extends StatefulWidget {
  final LeaseContract lease;

  const LeaseContractScreen({super.key, required this.lease});

  @override
  State<LeaseContractScreen> createState() => _LeaseContractScreenState();
}

class _LeaseContractScreenState extends State<LeaseContractScreen> {
  bool _canAccept = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Contrat de bail", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue[900], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lease.propertyName ?? "Bien Immobilier",
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Loyer mensuel: ${widget.lease.monthlyRent.toStringAsFixed(0)} FCFA",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Veuillez lire attentivement l'intégralité du contrat pour pouvoir le signer.",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ContractViewer(
                contractText: widget.lease.contractText,
                onReadComplete: (completed) {
                  setState(() => _canAccept = completed);
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _canAccept
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeaseSignatureScreen(leaseId: widget.lease.id),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text("J'accepte et je signe"),
            ),
          ],
        ),
      ),
    );
  }
}

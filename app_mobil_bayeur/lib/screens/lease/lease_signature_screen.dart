import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/widgets/signature_pad.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';
import 'package:app_mobil_bayeur/services/lease_service.dart';
import 'package:local_auth/local_auth.dart';

class LeaseSignatureScreen extends ConsumerStatefulWidget {
  final String leaseId;

  const LeaseSignatureScreen({super.key, required this.leaseId});

  @override
  ConsumerState<LeaseSignatureScreen> createState() => _LeaseSignatureScreenState();
}

class _LeaseSignatureScreenState extends ConsumerState<LeaseSignatureScreen> {

  bool _isSubmitting = false;
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> _authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return true; // Fallback if no biometrics

      return await _auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour signer le contrat de bail',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      debugPrint("Erreur biométrique: $e");
      return false;
    }
  }

  Future<void> _handleSignature(Uint8List signatureData) async {
    final authenticated = await _authenticate();
    if (!mounted) return;
    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentification requise pour signer")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final leaseService = LeaseService(ApiService());
      final signatureBase64 = base64Encode(signatureData);
      
      // Assume the role is TENANT for now (as the requester usually starts the signature)
      await leaseService.signLease(widget.leaseId, 'tenant', signatureBase64);
      
      setState(() {

        _isSubmitting = false;
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de l'enregistrement: $e")));
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
        content: const Text(
          "Votre signature a été enregistrée avec succès. Le propriétaire sera notifié pour signer sa partie.",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Retour à l'accueil"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Signature du bail", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Cachet électronique de signature",
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            const SizedBox(height: 12),
            const Text(
              "Veuillez dessiner votre signature ci-dessous. En validant, vous reconnaissez avoir lu et accepté les termes du contrat.",
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: SignaturePad(
                  onSignatureSaved: _handleSignature,
                  onClear: () {},
                ),
              ),
            ),
            if (_isSubmitting)
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}

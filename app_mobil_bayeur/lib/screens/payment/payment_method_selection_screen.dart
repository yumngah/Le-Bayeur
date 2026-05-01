import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_mobil_bayeur/models/payment_model.dart';
import 'package:app_mobil_bayeur/models/lease_contract_model.dart';
import 'package:app_mobil_bayeur/services/payment_service.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class PaymentMethodSelectionScreen extends StatefulWidget {
  final LeaseContract lease;
  final double amount;

  const PaymentMethodSelectionScreen({
    super.key,
    required this.lease,
    required this.amount,
  });

  @override
  State<PaymentMethodSelectionScreen> createState() => _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState extends State<PaymentMethodSelectionScreen> {
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  void _handlePayment(PaymentMethod method, String provider) async {
    if (method == PaymentMethod.MOBILE_MONEY && _phoneController.text.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Numéro de téléphone invalide")));
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      final paymentService = PaymentService(ApiService());
      final payment = await paymentService.initiatePayment(
        widget.lease.id,
        widget.amount,
        method,
        provider: provider,
      );

      // Simulate a successful payment and verification
      await Future.delayed(const Duration(seconds: 2));
      await paymentService.confirmPayment(payment.id, "TEST_TRANS_123");

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Échec du paiement: $e")));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
        content: const Text(
          "Paiement effectué avec succès ! Votre facture a été générée et est disponible dans votre historique.",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Fermer"),
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
        title: Text("Paiement du loyer", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAmountSummary(),
            const SizedBox(height: 32),
            Text("Choisissez un mode de paiement", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildPaymentOption(
              "Orange Money", 
              "assets/images/om_logo.png", // Use placeholder or local assets
              Colors.orange[50]!, 
              () => _showPhoneDialog("Orange Money", "ORANGE"),
              icon: Icons.smartphone,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              "MTN Mobile Money", 
              "assets/images/mtn_logo.png", 
              Colors.yellow[50]!, 
              () => _showPhoneDialog("MTN Mobile Money", "MTN"),
              icon: Icons.smartphone,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              "Carte Bancaire", 
              "assets/images/visa_logo.png", 
              Colors.blue[50]!, 
              () => _handlePayment(PaymentMethod.CARD, "VISA"),
              icon: Icons.credit_card,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text("Montant à régler", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            "${widget.amount.toStringAsFixed(0)} FCFA",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Bien:", style: TextStyle(color: Colors.white70)),
              Text(widget.lease.propertyName ?? "N/A", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String logoPath, Color color, VoidCallback onTap, {IconData? icon}) {
    return InkWell(
      onTap: _isProcessing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon ?? Icons.payment, color: Colors.blue[900], size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showPhoneDialog(String providerName, String provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payer par $providerName"),
        content: TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: "6XXXXXXXX",
            labelText: "Numéro de téléphone",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePayment(PaymentMethod.MOBILE_MONEY, provider);
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }
}

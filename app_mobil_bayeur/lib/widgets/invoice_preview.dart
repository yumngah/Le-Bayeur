import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:app_mobil_bayeur/models/payment_model.dart';
import 'package:app_mobil_bayeur/models/lease_contract_model.dart';
import 'package:app_mobil_bayeur/services/invoice_service.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoicePreview extends StatelessWidget {
  final Payment payment;
  final LeaseContract lease;

  const InvoicePreview({
    super.key,
    required this.payment,
    required this.lease,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aperçu de la facture", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: PdfPreview(
        build: (format) async {
          final invoiceService = InvoiceService();
          final file = await invoiceService.generateInvoicePdf(payment, lease);
          return file.readAsBytes();
        },
        canDebug: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        actions: [
          PdfPreviewAction(
            icon: const Icon(Icons.share),
            onPressed: (context, build, format) async {
              final bytes = await build(format);
              await Printing.sharePdf(bytes: bytes, filename: "facture_${payment.id}.pdf");
            },
          ),
        ],
      ),
    );
  }
}

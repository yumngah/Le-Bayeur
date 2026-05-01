import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:app_mobil_bayeur/models/payment_model.dart';
import 'package:app_mobil_bayeur/models/lease_contract_model.dart';
import 'package:intl/intl.dart';

class InvoiceService {
  Future<File> generateInvoicePdf(Payment payment, LeaseContract lease) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(payment.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('FACTURE DE LOYER - BAYEURS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24)),
                    pw.Text('Ref: ${payment.referenceNumber ?? payment.id}', style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PROPRIÉTAIRE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(lease.landlordName ?? 'N/A'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('LOCATAIRE:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(lease.tenantName ?? 'N/A'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Description', 'Période', 'Montant'],
                data: [
                  [
                    'Location: ${lease.propertyName ?? 'Bien Immobilier'}',
                    DateFormat('MMMM yyyy', 'fr_FR').format(payment.createdAt),
                    '${payment.amount.toStringAsFixed(0)} FCFA'
                  ],
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Moyen de paiement: ${payment.method.name} (${payment.provider ?? ''})'),
                  pw.Text('TOTAL: ${payment.amount.toStringAsFixed(0)} FCFA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
                ],
              ),
              pw.SizedBox(height: 60),
              pw.Divider(),
              pw.Center(child: pw.Text('Document généré le $dateStr', style: const pw.TextStyle(color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/facture_${payment.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}

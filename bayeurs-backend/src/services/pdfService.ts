import PDFDocument from 'pdfkit';
import fs from 'fs';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';

export class PDFService {
  static async generateInvoice(paymentData: any, leaseData: any): Promise<string> {
    const doc = new PDFDocument({ margin: 50 });
    const fileName = `invoice_${uuidv4()}.pdf`;
    const filePath = path.resolve(`./uploads/${fileName}`);
    const stream = fs.createWriteStream(filePath);

    return new Promise((resolve, reject) => {
      doc.pipe(stream);

      // Header
      doc.fillColor('#444444').fontSize(20).text('BAYEURS - REÇU DE PAIEMENT', 110, 57);
      doc.fontSize(10).text('Email: support@bayeurs.com', 200, 65, { align: 'right' });
      doc.text('Tel: +237 000 000 000', 200, 80, { align: 'right' });
      doc.moveDown();

      // Horizontal Line
      doc.strokeColor('#aaaaaa').lineWidth(1).moveTo(50, 100).lineTo(550, 100).stroke();

      // Invoice Details
      doc.fontSize(10).text(`Facture N°: ${paymentData.id}`, 50, 120);
      doc.text(`Date: ${new Date(paymentData.created_at).toLocaleDateString()}`, 50, 135);
      doc.text(`Période: ${new Date(paymentData.period_start).toLocaleDateString()} - ${new Date(paymentData.period_end).toLocaleDateString()}`, 50, 150);

      // Parties
      doc.fontSize(12).text('Locataire:', 50, 180, { underline: true });
      doc.fontSize(10).text(leaseData.tenant_name, 50, 200);
      doc.text(leaseData.tenant_email, 50, 215);

      doc.fontSize(12).text('Propriétaire:', 350, 180, { underline: true });
      doc.fontSize(10).text(leaseData.landlord_name, 350, 200);
      doc.text(leaseData.landlord_email, 350, 215);

      // Property Info
      doc.moveDown(5);
      doc.fontSize(12).text('Propriété:', 50, 260, { underline: true });
      doc.fontSize(10).text(`${leaseData.property_name} - ${leaseData.property_location}`, 50, 280);

      // Payment Table
      const tableTop = 330;
      doc.strokeColor('#aaaaaa').lineWidth(1).moveTo(50, tableTop).lineTo(550, tableTop).stroke();
      doc.fontSize(10).font('Helvetica-Bold').text('Description', 50, tableTop + 10);
      doc.text('Mode de Paiement', 250, tableTop + 10);
      doc.text('Montant (XAF)', 450, tableTop + 10);
      doc.strokeColor('#aaaaaa').lineWidth(1).moveTo(50, tableTop + 30).lineTo(550, tableTop + 30).stroke();

      doc.font('Helvetica').text('Loyer Mensuel', 50, tableTop + 40);
      doc.text(paymentData.payment_method, 250, tableTop + 40);
      doc.text(paymentData.amount.toLocaleString(), 450, tableTop + 40);

      // Total
      doc.moveDown(5);
      doc.fontSize(14).font('Helvetica-Bold').text(`TOTAL: ${paymentData.amount.toLocaleString()} XAF`, { align: 'right' });

      // Footer
      doc.fontSize(10).font('Helvetica').text('Merci pour votre confiance.', 50, 700, { align: 'center', width: 500 });

      doc.end();

      stream.on('finish', () => resolve(`/uploads/${fileName}`));
      stream.on('error', (err) => reject(err));
    });
  }
}

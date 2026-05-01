import { query } from '../config/database.js';
import { PDFService } from './pdfService.js';
import { LeaseService } from './leaseService.js';
import nodemailer from 'nodemailer';
import { logger } from '../server.js';

export class PaymentService {
  static async createPayment(paymentData: any) {
    const { lease_id, amount, period_start, period_end, payment_method } = paymentData;
    const sql = `
      INSERT INTO payments (lease_id, amount, period_start, period_end, payment_method)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;
    const result = await query(sql, [lease_id, amount, period_start, period_end, payment_method]);
    return result.rows[0];
  }

  static async confirmPayment(id: string, transactionId: string, proofUrl?: string) {
    const sql = `
      UPDATE payments 
      SET transaction_id = $1, payment_proof_url = $2, status = 'COMPLETED', paid_at = NOW()
      WHERE id = $3
      RETURNING *;
    `;
    const result = await query(sql, [transactionId, proofUrl, id]);
    const payment = result.rows[0];

    if (payment) {
      // Generate PDF Invoice
      const lease = await LeaseService.getLeaseById(payment.lease_id);
      const invoiceUrl = await PDFService.generateInvoice(payment, lease);
      
      // Update payment with invoice URL
      await query('UPDATE payments SET invoice_url = $1 WHERE id = $2', [invoiceUrl, id]);
      payment.invoice_url = invoiceUrl;

      // Send Email Notification
      await this.sendPaymentNotification(payment, lease);
    }

    return payment;
  }

  static async getPaymentsByLease(leaseId: string) {
    const sql = 'SELECT * FROM payments WHERE lease_id = $1 ORDER BY created_at DESC;';
    const result = await query(sql, [leaseId]);
    return result.rows;
  }

  static async getPaymentCalendar(userId: string, year: number, month: number) {
    const startDate = `${year}-${month.toString().padStart(2, '0')}-01`;
    const endDate = new Date(year, month, 0).toISOString().split('T')[0];

    const sql = `
      SELECT p.*, l.property_id, prop.name as property_name
      FROM payments p
      JOIN leases l ON p.lease_id = l.id
      JOIN properties prop ON l.property_id = prop.id
      WHERE (l.tenant_id = $1 OR l.landlord_id = $1)
      AND p.period_start >= $2 AND p.period_end <= $3;
    `;
    const result = await query(sql, [userId, startDate, endDate]);
    return result.rows;
  }

  private static async sendPaymentNotification(payment: any, lease: any) {
    try {
      const transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: parseInt(process.env.SMTP_PORT || '587'),
        secure: false,
        auth: {
          user: process.env.SMTP_USER,
          pass: process.env.SMTP_PASSWORD,
        },
      });

      const mailOptions = {
        from: `"${process.env.SMTP_FROM_NAME}" <${process.env.SMTP_FROM_EMAIL}>`,
        to: `${lease.tenant_email}, ${lease.landlord_email}`,
        subject: 'Confirmation de paiement - Bayeurs',
        text: `Le paiement de ${payment.amount} XAF pour le bien ${lease.property_name} a été confirmé. Facture disponible à: ${payment.invoice_url}`,
        html: `
          <h3>Confirmation de paiement</h3>
          <p>Le paiement de <strong>${payment.amount} XAF</strong> pour le bien <strong>${lease.property_name}</strong> a été confirmé.</p>
          <p>Facture jointe à votre compte ou disponible <a href="${process.env.BASE_URL}${payment.invoice_url}">ici</a>.</p>
        `,
      };

      await transporter.sendMail(mailOptions);
      logger.info(`Email sent for payment confirmation ${payment.id}`);
    } catch (error) {
      logger.error(`Failed to send email for payment ${payment.id}: ${error}`);
    }
  }
}

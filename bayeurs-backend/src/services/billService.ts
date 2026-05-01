import { query } from '../config/database.js';
import nodemailer from 'nodemailer';
import { logger } from '../server.js';

export class BillService {
  static async createBill(billData: any) {
    const { user_id, type, amount, due_date } = billData;
    const sql = `
      INSERT INTO bills (user_id, type, amount, due_date)
      VALUES ($1, $2, $3, $4)
      RETURNING *;
    `;
    const result = await query(sql, [user_id, type, amount, due_date]);
    return result.rows[0];
  }

  static async getBillsByUser(userId: string) {
    const sql = 'SELECT * FROM bills WHERE user_id = $1 ORDER BY due_date ASC;';
    const result = await query(sql, [userId]);
    return result.rows;
  }

  static async markAsPaid(billId: string, userId: string) {
    const sql = `
      UPDATE bills 
      SET status = 'PAID', paid_at = NOW() 
      WHERE id = $1 AND user_id = $2 
      RETURNING *;
    `;
    const result = await query(sql, [billId, userId]);
    return result.rows[0];
  }

  static async getBillCalendar(userId: string, year: number, month: number) {
    const startDate = `${year}-${month.toString().padStart(2, '0')}-01`;
    const endDate = new Date(year, month, 0).toISOString().split('T')[0];

    const sql = `
      SELECT * FROM bills 
      WHERE user_id = $1 
      AND due_date >= $2 AND due_date <= $3;
    `;
    const result = await query(sql, [userId, startDate, endDate]);
    return result.rows;
  }

  static async sendReminder(billId: string, userId: string) {
    const billSql = 'SELECT b.*, u.email, u.username FROM bills b JOIN users u ON b.user_id = u.id WHERE b.id = $1 AND b.user_id = $2;';
    const result = await query(billSql, [billId, userId]);
    const bill = result.rows[0];

    if (!bill || bill.status === 'PAID') return null;

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
        to: bill.email,
        subject: `Rappel de facture : ${bill.type}`,
        text: `Bonjour ${bill.username}, n'oubliez pas de régler votre facture de ${bill.amount} XAF avant le ${new Date(bill.due_date).toLocaleDateString()}.`,
        html: `
          <h3>Rappel de paiement</h3>
          <p>Bonjour <strong>${bill.username}</strong>,</p>
          <p>Ceci est un rappel pour votre facture de <strong>${bill.type}</strong> d'un montant de <strong>${bill.amount} XAF</strong>.</p>
          <p>Date d'échéance : <strong>${new Date(bill.due_date).toLocaleDateString()}</strong></p>
          <p>Merci de procéder au règlement via l'application.</p>
        `,
      };

      await transporter.sendMail(mailOptions);
      logger.info(`Reminder sent for bill ${bill.id}`);
      return true;
    } catch (error) {
      logger.error(`Failed to send reminder for bill ${bill.id}: ${error}`);
      return false;
    }
  }
}

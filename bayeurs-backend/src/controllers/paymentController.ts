import { Response, NextFunction } from 'express';
import { PaymentService } from '../services/paymentService.js';
import { AuthRequest } from '../middleware/auth.js';

export class PaymentController {
  static async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const payment = await PaymentService.createPayment(req.body);
      res.status(201).json(payment);
    } catch (error) {
      next(error);
    }
  }

  static async confirm(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { transaction_id, proof_url } = req.body;
      const payment = await PaymentService.confirmPayment(id, transaction_id, proof_url);
      if (!payment) return res.status(404).json({ message: 'Payment not found' });
      res.status(200).json(payment);
    } catch (error) {
      next(error);
    }
  }

  static async getByLease(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { leaseId } = req.params;
      const payments = await PaymentService.getPaymentsByLease(leaseId);
      res.status(200).json(payments);
    } catch (error) {
      next(error);
    }
  }

  static async getCalendar(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { year, month } = req.query;
      const calendar = await PaymentService.getPaymentCalendar(
        req.user.id, 
        parseInt(year as string || new Date().getFullYear().toString()), 
        parseInt(month as string || (new Date().getMonth() + 1).toString())
      );
      res.status(200).json(calendar);
    } catch (error) {
      next(error);
    }
  }
}

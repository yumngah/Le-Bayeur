import { Response, NextFunction } from 'express';
import { BillService } from '../services/billService.js';
import { AuthRequest } from '../middleware/auth.js';
import { billSchema } from '../utils/validators.js';

export class BillController {
  static async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { error } = billSchema.validate(req.body);
      if (error) return res.status(400).json({ message: error.details[0].message });

      const bill = await BillService.createBill({ ...req.body, user_id: req.user.id });
      res.status(201).json(bill);
    } catch (error) {
      next(error);
    }
  }

  static async getMyBills(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const bills = await BillService.getBillsByUser(req.user.id);
      res.status(200).json(bills);
    } catch (error) {
      next(error);
    }
  }

  static async markPaid(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const bill = await BillService.markAsPaid(id, req.user.id);
      if (!bill) return res.status(404).json({ message: 'Bill not found or unauthorized' });
      res.status(200).json(bill);
    } catch (error) {
      next(error);
    }
  }

  static async getCalendar(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { year, month } = req.query;
      const calendar = await BillService.getBillCalendar(
        req.user.id, 
        parseInt(year as string || new Date().getFullYear().toString()), 
        parseInt(month as string || (new Date().getMonth() + 1).toString())
      );
      res.status(200).json(calendar);
    } catch (error) {
      next(error);
    }
  }

  static async remind(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const success = await BillService.sendReminder(id, req.user.id);
      if (success === null) return res.status(404).json({ message: 'Bill not found or already paid' });
      if (!success) return res.status(500).json({ message: 'Failed to send reminder' });
      res.status(200).json({ message: 'Reminder sent successfully' });
    } catch (error) {
      next(error);
    }
  }
}

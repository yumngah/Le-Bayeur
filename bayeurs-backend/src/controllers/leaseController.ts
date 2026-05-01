import { Response, NextFunction } from 'express';
import { LeaseService } from '../services/leaseService.js';
import { AuthRequest } from '../middleware/auth.js';

export class LeaseController {
  static async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const lease = await LeaseService.createLease(req.body);
      res.status(201).json(lease);
    } catch (error) {
      next(error);
    }
  }

  static async sign(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { role, signature } = req.body;
      const lease = await LeaseService.signLease(id, req.user.id, role, signature);
      if (!lease) return res.status(404).json({ message: 'Lease not found or unauthorized' });
      res.status(200).json(lease);
    } catch (error) {
      next(error);
    }
  }

  static async getMyLeases(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const role = req.user.role === 'TENANT' ? 'tenant' : 'landlord';
      const leases = await LeaseService.getLeasesByUser(req.user.id, role);
      res.status(200).json(leases);
    } catch (error) {
      next(error);
    }
  }

  static async terminate(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const lease = await LeaseService.terminateLease(id, req.user.id);
      if (!lease) return res.status(404).json({ message: 'Lease not found or unauthorized' });
      res.status(200).json(lease);
    } catch (error) {
      next(error);
    }
  }
}

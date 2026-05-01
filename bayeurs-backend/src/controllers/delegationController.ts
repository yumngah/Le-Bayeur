import { Response, NextFunction } from 'express';
import { DelegationService } from '../services/delegationService.js';
import { AuthRequest } from '../middleware/auth.js';

export class DelegationController {
  static async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { delegate_email, permissions } = req.body;
      const delegation = await DelegationService.createInvitation(req.user.id, delegate_email, permissions);
      res.status(201).json(delegation);
    } catch (error) {
      next(error);
    }
  }

  static async getMine(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const delegations = await DelegationService.getDelegationsByOwner(req.user.id);
      res.status(200).json(delegations);
    } catch (error) {
      next(error);
    }
  }

  static async getAssigned(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const delegations = await DelegationService.getDelegationsByDelegate(req.user.id);
      res.status(200).json(delegations);
    } catch (error) {
      next(error);
    }
  }

  static async accept(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { code } = req.body;
      const delegation = await DelegationService.acceptInvitation(req.user.id, code);
      if (!delegation) {
        return res.status(400).json({ message: 'Invalid or expired invitation code' });
      }
      res.status(200).json(delegation);
    } catch (error) {
      next(error);
    }
  }

  static async revoke(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const delegation = await DelegationService.revokeDelegation(req.user.id, id);
      if (!delegation) {
        return res.status(404).json({ message: 'Delegation not found or unauthorized' });
      }
      res.status(200).json({ message: 'Delegation revoked successfully' });
    } catch (error) {
      next(error);
    }
  }
}

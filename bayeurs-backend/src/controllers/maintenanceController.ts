import { Response, NextFunction } from 'express';
import { TechnicianService, MaintenanceService } from '../services/maintenanceService.js';
import { AuthRequest } from '../middleware/auth.js';

export class TechnicianController {
  static async register(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { specialty, bio } = req.body;
      const technician = await TechnicianService.register(req.user.id, specialty, bio);
      res.status(201).json(technician);
    } catch (error) {
      next(error);
    }
  }

  static async search(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { specialty, available } = req.query;
      const technicians = await TechnicianService.search(specialty as string, available === 'true');
      res.status(200).json(technicians);
    } catch (error) {
      next(error);
    }
  }
}

export class MaintenanceController {
  static async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { property_id, description, urgency } = req.body;
      const request = await MaintenanceService.createRequest(property_id, req.user.id, description, urgency);
      res.status(201).json(request);
    } catch (error) {
      next(error);
    }
  }

  static async assign(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { technician_id } = req.body;
      const request = await MaintenanceService.assignTechnician(id, technician_id);
      res.status(200).json(request);
    } catch (error) {
      next(error);
    }
  }

  static async statusUpdate(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { status } = req.body;
      const request = await MaintenanceService.updateStatus(id, status);
      res.status(200).json(request);
    } catch (error) {
      next(error);
    }
  }

  static async getByProperty(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { propertyId } = req.params;
      const requests = await MaintenanceService.getByProperty(propertyId);
      res.status(200).json(requests);
    } catch (error) {
      next(error);
    }
  }
}

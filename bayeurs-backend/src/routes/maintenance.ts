import { Router } from 'express';
import { MaintenanceController, TechnicianController } from '../controllers/maintenanceController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

router.use(authenticate);

// Technician Routes
router.post('/technicians/register', TechnicianController.register);
router.get('/technicians/search', TechnicianController.search);

// Maintenance Routes
router.post('/requests', MaintenanceController.create);
router.get('/property/:propertyId', MaintenanceController.getByProperty);
router.patch('/requests/:id/assign', MaintenanceController.assign);
router.patch('/requests/:id/status', MaintenanceController.statusUpdate);

export default router;

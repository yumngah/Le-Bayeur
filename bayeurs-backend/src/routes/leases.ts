import { Router } from 'express';
import { LeaseController } from '../controllers/leaseController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

router.use(authenticate);

router.post('/', LeaseController.create);
router.post('/:id/sign', LeaseController.sign);
router.get('/my', LeaseController.getMyLeases);
router.post('/:id/terminate', LeaseController.terminate);

export default router;

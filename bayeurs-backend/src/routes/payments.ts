import { Router } from 'express';
import { PaymentController } from '../controllers/paymentController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

router.use(authenticate);

router.post('/', PaymentController.create);
router.post('/:id/confirm', PaymentController.confirm);
router.get('/lease/:leaseId', PaymentController.getByLease);
router.get('/calendar', PaymentController.getCalendar);

export default router;

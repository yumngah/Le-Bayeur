import { Router } from 'express';
import { BillController } from '../controllers/billController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

router.use(authenticate);

router.post('/', BillController.create);
router.get('/my', BillController.getMyBills);
router.patch('/:id/paid', BillController.markPaid);
router.get('/calendar', BillController.getCalendar);
router.post('/:id/remind', BillController.remind);

export default router;

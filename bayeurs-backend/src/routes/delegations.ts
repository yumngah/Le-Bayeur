import { Router } from 'express';
import { DelegationController } from '../controllers/delegationController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

router.use(authenticate);

router.post('/', DelegationController.create);
router.get('/mine', DelegationController.getMine);
router.get('/assigned', DelegationController.getAssigned);
router.post('/accept', DelegationController.accept);
router.delete('/:id', DelegationController.revoke);

export default router;

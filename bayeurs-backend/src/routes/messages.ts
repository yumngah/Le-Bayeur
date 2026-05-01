import { Router } from 'express';
import { MessageController } from '../controllers/messageController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

router.use(authenticate);

router.post('/', MessageController.send);
router.get('/conversations', MessageController.getChatList);
router.get('/conversation/:otherUserId', MessageController.getConversation);
router.put('/read/:senderId', MessageController.markRead);
router.delete('/:id', MessageController.delete);

export default router;

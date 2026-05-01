import { Router } from 'express';
import { CommentController } from '../controllers/commentController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

// Public Routes (Anyone can see comments)
router.get('/property/:propertyId', CommentController.getByProperty);

// Protected Routes (Only logged in users can post/interact)
router.post('/', authenticate, CommentController.post);
router.post('/:id/interact', authenticate, CommentController.interact);
router.post('/:id/report', authenticate, CommentController.report);
router.delete('/:id', authenticate, CommentController.delete);

export default router;

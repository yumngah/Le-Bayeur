import { Router } from 'express';
import { AuthController } from '../controllers/authController.js';
import { authenticate } from '../middleware/auth.js';

const router = Router();

// Public Routes
router.post('/signup', AuthController.signup);
router.post('/login', AuthController.login);
router.post('/verify-email', AuthController.verifyEmail);
router.post('/verify-phone', AuthController.verifyPhone);
router.post('/refresh-token', AuthController.refreshToken);

// Protected Routes
router.post('/logout', authenticate, AuthController.logout);

export default router;

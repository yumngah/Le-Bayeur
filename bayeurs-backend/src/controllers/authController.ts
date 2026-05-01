import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/authService.js';
import { signupSchema, loginSchema, verifySchema } from '../utils/validators.js';
import { logger } from '../server.js';

export class AuthController {
  static async signup(req: Request, res: Response, next: NextFunction) {
    try {
      const { error } = signupSchema.validate(req.body);
      if (error) return res.status(400).json({ message: error.details[0].message });

      const { username, email, phone_number, password, role } = req.body;

      const existingEmail = await AuthService.findUserByEmail(email);
      if (existingEmail) return res.status(400).json({ message: 'Email already exists' });

      const existingPhone = await AuthService.findUserByPhone(phone_number);
      if (existingPhone) return res.status(400).json({ message: 'Phone number already exists' });

      const password_hash = await AuthService.hashPassword(password);
      const user = await AuthService.createUser({ username, email, phone_number, password_hash, role });

      const emailCode = AuthService.generateVerificationCode();
      const phoneCode = AuthService.generateVerificationCode();
      await AuthService.updateVerificationCodes(user.id, emailCode, phoneCode);

      // In production, send via emailService and notificationService
      logger.info(`Verification codes for ${user.id}: Email=${emailCode}, Phone=${phoneCode}`);

      const token = AuthService.generateToken(user.id);
      const refreshToken = AuthService.generateRefreshToken(user.id);

      logger.info(`User signed up: ${user.email} with role: ${role}`);
      res.status(201).json({
        message: 'User created successfully. Please verify your email and phone.',
        token,
        refreshToken,
        user
      });
    } catch (error) {
      logger.error(`Signup failed: ${error}`);
      next(error);
    }
  }

  static async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { error } = loginSchema.validate(req.body);
      if (error) return res.status(400).json({ message: error.details[0].message });

      const { email, password } = req.body;
      const user = await AuthService.findUserByEmail(email);

      if (!user || !(await AuthService.comparePasswords(password, user.password_hash))) {
        logger.warn(`Failed login attempt for: ${email}`);
        return res.status(401).json({ message: 'Invalid email or password' });
      }

      logger.info(`User logged in: ${user.email}`);
      const token = AuthService.generateToken(user.id);
      const refreshToken = AuthService.generateRefreshToken(user.id);

      res.status(200).json({
        token,
        refreshToken,
        user: { id: user.id, username: user.username, email: user.email, role: user.role }
      });
    } catch (error) {
      next(error);
    }
  }

  static async verifyEmail(req: Request, res: Response, next: NextFunction) {
    try {
      const { error } = verifySchema.validate(req.body);
      if (error) return res.status(400).json({ message: error.details[0].message });

      const { user_id, code } = req.body;
      const success = await AuthService.verifyCode(user_id, 'email', code);

      if (!success) {
        logger.warn(`Email verification failed for user: ${user_id}`);
        return res.status(400).json({ message: 'Invalid or expired verification code' });
      }

      logger.info(`Email verified for user: ${user_id}`);
      res.status(200).json({ message: 'Email verified successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async verifyPhone(req: Request, res: Response, next: NextFunction) {
    try {
      const { error } = verifySchema.validate(req.body);
      if (error) return res.status(400).json({ message: error.details[0].message });

      const { user_id, code } = req.body;
      const success = await AuthService.verifyCode(user_id, 'phone', code);

      if (!success) return res.status(400).json({ message: 'Invalid or expired verification code' });

      res.status(200).json({ message: 'Phone verified successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async refreshToken(req: Request, res: Response, next: NextFunction) {
    try {
      const { refreshToken } = req.body;
      if (!refreshToken) return res.status(400).json({ message: 'Refresh token is required' });

      const decoded = AuthService.verifyRefreshToken(refreshToken);
      const user = await AuthService.findUserById(decoded.id);

      if (!user) return res.status(401).json({ message: 'User not found' });

      const newToken = AuthService.generateToken(user.id);
      res.status(200).json({ token: newToken });
    } catch (error) {
      res.status(401).json({ message: 'Invalid or expired refresh token' });
    }
  }

  static async logout(req: Request, res: Response, next: NextFunction) {
    try {
      // In a more complex implementation, we might blacklist the token
      res.status(200).json({ message: 'Logged out successfully' });
    } catch (error) {
      next(error);
    }
  }
}

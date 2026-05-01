import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../config/database.js';
import dotenv from 'dotenv';
import { logger } from '../server.js';

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRE || '7d';
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'super-refresh-secret';
const REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRE || '30d';

export class AuthService {
  static async hashPassword(password: string): Promise<string> {
    const salt = await bcrypt.genSalt(10);
    return await bcrypt.hash(password, salt);
  }

  static async comparePasswords(password: string, hash: string): Promise<boolean> {
    return await bcrypt.compare(password, hash);
  }

  static generateToken(userId: string): string {
    return jwt.sign({ id: userId }, JWT_SECRET, {
      expiresIn: JWT_EXPIRES_IN as any,
    });
  }

  static generateRefreshToken(userId: string): string {
    return jwt.sign({ id: userId }, REFRESH_SECRET, {
      expiresIn: REFRESH_EXPIRES_IN as any,
    });
  }

  static verifyRefreshToken(token: string): any {
    return jwt.verify(token, REFRESH_SECRET);
  }

  static generateVerificationCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  static async createUser(userData: any) {
    const { username, email, phone_number, password_hash, role } = userData;
    const sql = `
      INSERT INTO users (username, email, phone_number, password_hash, role)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, username, email, role, is_email_verified, is_phone_verified;
    `;
    const result = await query(sql, [username, email, phone_number, password_hash, role]);
    return result.rows[0];
  }

  static async findUserByEmail(email: string) {
    const sql = 'SELECT * FROM users WHERE email = $1;';
    const result = await query(sql, [email]);
    return result.rows[0];
  }

  static async findUserById(id: string) {
    const sql = 'SELECT * FROM users WHERE id = $1;';
    const result = await query(sql, [id]);
    return result.rows[0];
  }

  static async findUserByPhone(phone: string) {
    const sql = 'SELECT * FROM users WHERE phone_number = $1;';
    const result = await query(sql, [phone]);
    return result.rows[0];
  }

  static async updateVerificationCodes(userId: string, emailCode: string, phoneCode: string) {
    const expiry = new Date();
    expiry.setMinutes(expiry.getMinutes() + 10); // 10 minutes validity

    const sql = `
      UPDATE users 
      SET email_verification_code = $1, 
          phone_verification_code = $2, 
          verification_code_expires_at = $3
      WHERE id = $4;
    `;
    await query(sql, [emailCode, phoneCode, expiry, userId]);
  }

  static async verifyCode(userId: string, type: 'email' | 'phone', code: string): Promise<boolean> {
    const column = type === 'email' ? 'email_verification_code' : 'phone_verification_code';
    const verifyColumn = type === 'email' ? 'is_email_verified' : 'is_phone_verified';
    
    const sql = `
      SELECT * FROM users 
      WHERE id = $1 AND ${column} = $2 AND verification_code_expires_at > NOW();
    `;
    const result = await query(sql, [userId, code]);
    
    if (result.rows.length > 0) {
      await query(`UPDATE users SET ${verifyColumn} = TRUE, ${column} = NULL WHERE id = $1;`, [userId]);
      return true;
    }
    return false;
  }
}

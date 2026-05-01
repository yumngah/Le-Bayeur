import { query } from '../config/database.js';
import crypto from 'crypto';

export class DelegationService {
  static async createInvitation(ownerId: string, delegateEmail: string, permissions: string[]) {
    const invitationCode = `BAYEURS_${crypto.randomBytes(4).toString('hex').toUpperCase()}`;
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30); // 30 days validity

    const sql = `
      INSERT INTO delegations (owner_id, delegate_email, invitation_code, invitation_expires_at, permissions)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;
    const result = await query(sql, [ownerId, delegateEmail, invitationCode, expiresAt, permissions]);
    return result.rows[0];
  }

  static async getDelegationsByOwner(ownerId: string) {
    const sql = `
      SELECT d.*, u.username as delegate_name, u.avatar_url as delegate_avatar
      FROM delegations d
      LEFT JOIN users u ON d.delegate_id = u.id
      WHERE d.owner_id = $1;
    `;
    const result = await query(sql, [ownerId]);
    return result.rows;
  }

  static async getDelegationsByDelegate(delegateId: string) {
    const sql = `
      SELECT d.*, u.username as owner_name, u.avatar_url as owner_avatar
      FROM delegations d
      JOIN users u ON d.owner_id = u.id
      WHERE d.delegate_id = $1 AND d.status = 'ACCEPTED';
    `;
    const result = await query(sql, [delegateId]);
    return result.rows;
  }

  static async acceptInvitation(delegateId: string, code: string) {
    const checkSql = `
      SELECT * FROM delegations 
      WHERE invitation_code = $1 AND status = 'PENDING' AND invitation_expires_at > NOW();
    `;
    const checkResult = await query(checkSql, [code]);
    if (checkResult.rows.length === 0) return null;

    const delegationId = checkResult.rows[0].id;
    const sql = `
      UPDATE delegations 
      SET delegate_id = $1, status = 'ACCEPTED', accepted_at = NOW(), updated_at = NOW()
      WHERE id = $2
      RETURNING *;
    `;
    const result = await query(sql, [delegateId, delegationId]);
    return result.rows[0];
  }

  static async revokeDelegation(ownerId: string, delegationId: string) {
    const sql = `
      UPDATE delegations 
      SET status = 'REVOKED', updated_at = NOW()
      WHERE id = $1 AND owner_id = $2
      RETURNING *;
    `;
    const result = await query(sql, [delegationId, ownerId]);
    return result.rows[0];
  }
}

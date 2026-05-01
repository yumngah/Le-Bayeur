import { query } from '../config/database.js';

export class LeaseService {
  static async createLease(leaseData: any) {
    const { property_id, tenant_id, landlord_id, monthly_rent, start_date, end_date, contract_text } = leaseData;
    const sql = `
      INSERT INTO leases (property_id, tenant_id, landlord_id, monthly_rent, start_date, end_date, contract_text)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
    `;
    const result = await query(sql, [property_id, tenant_id, landlord_id, monthly_rent, start_date, end_date, contract_text]);
    return result.rows[0];
  }

  static async signLease(leaseId: string, userId: string, role: 'tenant' | 'landlord', signature: string) {
    const column = role === 'tenant' ? 'tenant_signature' : 'landlord_signature';
    const userColumn = role === 'tenant' ? 'tenant_id' : 'landlord_id';

    const sql = `
      UPDATE leases 
      SET ${column} = $1, 
          signed_at = CASE WHEN (tenant_signature IS NOT NULL OR landlord_signature IS NOT NULL) THEN NOW() ELSE signed_at END,
          status = CASE WHEN (tenant_signature IS NOT NULL AND landlord_signature IS NOT NULL) OR ($1 IS NOT NULL AND (${role === 'tenant' ? 'landlord_signature' : 'tenant_signature'} IS NOT NULL)) THEN 'ACTIVE'::lease_status ELSE status END
      WHERE id = $2 AND ${userColumn} = $3
      RETURNING *;
    `;
    const result = await query(sql, [signature, leaseId, userId]);
    return result.rows[0];
  }

  static async getLeasesByUser(userId: string, role: 'tenant' | 'landlord') {
    const column = role === 'tenant' ? 'tenant_id' : 'landlord_id';
    const sql = `
      SELECT l.*, p.name as property_name, u.username as other_party_name
      FROM leases l
      JOIN properties p ON l.property_id = p.id
      JOIN users u ON u.id = (CASE WHEN l.tenant_id = $1 THEN l.landlord_id ELSE l.tenant_id END)
      WHERE l.${column} = $1
      ORDER BY l.created_at DESC;
    `;
    const result = await query(sql, [userId]);
    return result.rows;
  }

  static async getLeaseById(id: string) {
    const sql = `
      SELECT l.*, p.name as property_name, p.location as property_location,
             t.username as tenant_name, t.email as tenant_email,
             lb.username as landlord_name, lb.email as landlord_email
      FROM leases l
      JOIN properties p ON l.property_id = p.id
      JOIN users t ON l.tenant_id = t.id
      JOIN users lb ON l.landlord_id = lb.id
      WHERE l.id = $1;
    `;
    const result = await query(sql, [id]);
    return result.rows[0];
  }

  static async terminateLease(id: string, userId: string) {
    const sql = `
      UPDATE leases SET status = 'TERMINATED' 
      WHERE id = $1 AND (tenant_id = $2 OR landlord_id = $2)
      RETURNING *;
    `;
    const result = await query(sql, [id, userId]);
    return result.rows[0];
  }
}

import { query } from '../config/database.js';

export class TechnicianService {
  static async register(userId: string, specialty: string, bio: string) {
    const sql = `
      INSERT INTO technicians (user_id, specialty, bio)
      VALUES ($1, $2, $3)
      RETURNING *;
    `;
    const result = await query(sql, [userId, specialty, bio]);
    return result.rows[0];
  }

  static async search(specialty?: string, availableOnly: boolean = false) {
    let sql = `
      SELECT t.*, u.username, u.phone 
      FROM technicians t 
      JOIN users u ON t.user_id = u.id 
      WHERE 1=1
    `;
    const params: any[] = [];
    
    if (specialty) {
      params.push(`%${specialty}%`);
      sql += ` AND t.specialty ILIKE $${params.length}`;
    }
    
    if (availableOnly) {
      sql += ` AND t.is_available = TRUE`;
    }

    const result = await query(sql, params);
    return result.rows;
  }
}

export class MaintenanceService {
  static async createRequest(propertyId: string, requesterId: string, description: string, urgency: string) {
    const sql = `
      INSERT INTO maintenance_requests (property_id, requester_id, description, urgency)
      VALUES ($1, $2, $3, $4)
      RETURNING *;
    `;
    const result = await query(sql, [propertyId, requesterId, description, urgency]);
    return result.rows[0];
  }

  static async assignTechnician(requestId: string, technicianId: string) {
    const sql = `
      UPDATE maintenance_requests 
      SET technician_id = $1, status = 'IN_PROGRESS', updated_at = NOW() 
      WHERE id = $2 
      RETURNING *;
    `;
    const result = await query(sql, [technicianId, requestId]);
    return result.rows[0];
  }

  static async updateStatus(requestId: string, status: string) {
    const sql = `
      UPDATE maintenance_requests 
      SET status = $1, updated_at = NOW() 
      WHERE id = $2 
      RETURNING *;
    `;
    const result = await query(sql, [status, requestId]);
    return result.rows[0];
  }

  static async getByProperty(propertyId: string) {
    const sql = `
      SELECT mr.*, t.specialty as technician_specialty, u.username as technician_name
      FROM maintenance_requests mr
      LEFT JOIN technicians t ON mr.technician_id = t.id
      LEFT JOIN users u ON t.user_id = u.id
      WHERE mr.property_id = $1
      ORDER BY mr.created_at DESC;
    `;
    const result = await query(sql, [propertyId]);
    return result.rows;
  }
}

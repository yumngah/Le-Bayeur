import { query } from '../config/database.js';

export class PropertyService {
  static async createProperty(ownerId: string, propertyData: any) {
    const { name, location, latitude, longitude, type, status, standing, sale_price, rent_price, description } = propertyData;
    const sql = `
      INSERT INTO properties (owner_id, name, location, latitude, longitude, type, status, standing, sale_price, rent_price, description)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *;
    `;
    const result = await query(sql, [ownerId, name, location, latitude, longitude, type, status, standing, sale_price, rent_price, description]);
    return result.rows[0];
  }

  static async getProperties(filters: any) {
    const { 
      status, type, standing, location, 
      min_price, max_price, 
      limit = 20, page = 1,
      sortBy = 'date', order = 'DESC'
    } = filters;
    const offset = (page - 1) * limit;
    
    let sql = `SELECT p.*, 
               (SELECT json_agg(pi.url) FROM property_images pi WHERE pi.property_id = p.id) as images
               FROM properties p WHERE 1=1`;
    const params: any[] = [];
    let paramIndex = 1;

    if (status) {
      sql += ` AND p.status = $${paramIndex++}`;
      params.push(status);
    }
    if (type) {
      sql += ` AND p.type = $${paramIndex++}`;
      params.push(type);
    }
    if (standing) {
      sql += ` AND p.standing = $${paramIndex++}`;
      params.push(standing);
    }
    if (location) {
      sql += ` AND p.location ILIKE $${paramIndex++}`;
      params.push(`%${location}%`);
    }
    if (min_price) {
      sql += ` AND (p.rent_price >= $${paramIndex} OR p.sale_price >= $${paramIndex++})`;
      params.push(min_price);
    }
    if (max_price) {
      sql += ` AND (p.rent_price <= $${paramIndex} OR p.sale_price <= $${paramIndex++})`;
      params.push(max_price);
    }

    // Sorting
    let sortColumn = 'p.created_at';
    if (sortBy === 'price') {
      sortColumn = 'COALESCE(p.rent_price, p.sale_price)';
    } else if (sortBy === 'popularity') {
      sortColumn = 'p.view_count';
    }

    sql += ` ORDER BY ${sortColumn} ${order === 'ASC' ? 'ASC' : 'DESC'}`;
    sql += ` LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
    params.push(limit, offset);

    const result = await query(sql, params);
    return result.rows;
  }

  static async getPropertyById(id: string) {
    const sql = `
      SELECT p.*, u.username as owner_name,
      (SELECT json_agg(pi.*) FROM property_images pi WHERE pi.property_id = p.id ORDER BY pi.display_order) as images
      FROM properties p
      JOIN users u ON p.owner_id = u.id
      WHERE p.id = $1;
    `;
    const result = await query(sql, [id]);
    return result.rows[0];
  }

  static async updateProperty(id: string, ownerId: string, updateData: any) {
    const fields = Object.keys(updateData);
    if (fields.length === 0) return null;

    const setClause = fields.map((field, index) => `${field} = $${index + 3}`).join(', ');
    const sql = `UPDATE properties SET ${setClause} WHERE id = $1 AND owner_id = $2 RETURNING *;`;
    const result = await query(sql, [id, ownerId, ...Object.values(updateData)]);
    return result.rows[0];
  }

  static async deleteProperty(id: string, ownerId: string) {
    const sql = 'DELETE FROM properties WHERE id = $1 AND owner_id = $2 RETURNING id;';
    const result = await query(sql, [id, ownerId]);
    return result.rows.length > 0;
  }

  static async addImage(propertyId: string, url: string, displayOrder: number = 0) {
    const sql = 'INSERT INTO property_images (property_id, url, display_order) VALUES ($1, $2, $3) RETURNING *;';
    const result = await query(sql, [propertyId, url, displayOrder]);
    return result.rows[0];
  }

  static async incrementViews(id: string) {
    await query('UPDATE properties SET view_count = view_count + 1 WHERE id = $1', [id]);
  }
}

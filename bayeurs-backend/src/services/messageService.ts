import { query } from '../config/database.js';

export class MessageService {
  static async sendMessage(senderId: string, receiverId: string, content: string, propertyId?: string) {
    const sql = `
      INSERT INTO messages (sender_id, receiver_id, content, property_id)
      VALUES ($1, $2, $3, $4)
      RETURNING *;
    `;
    const result = await query(sql, [senderId, receiverId, content, propertyId]);
    return result.rows[0];
  }

  static async getConversation(userId1: string, userId2: string, limit: number = 50, offset: number = 0) {
    const sql = `
      SELECT m.*, 
             s.username as sender_name, 
             r.username as receiver_name
      FROM messages m
      JOIN users s ON m.sender_id = s.id
      JOIN users r ON m.receiver_id = r.id
      WHERE (m.sender_id = $1 AND m.receiver_id = $2)
         OR (m.sender_id = $2 AND m.receiver_id = $1)
      ORDER BY m.created_at DESC
      LIMIT $3 OFFSET $4;
    `;
    const result = await query(sql, [userId1, userId2, limit, offset]);
    return result.rows;
  }

  static async getConversationsList(userId: string) {
    const sql = `
      SELECT DISTINCT ON (other_id)
             CASE WHEN m.sender_id = $1 THEN m.receiver_id ELSE m.sender_id END as other_id,
             u.username as other_name,
             m.content as last_message,
             m.created_at as last_message_time,
             m.is_read
      FROM messages m
      JOIN users u ON u.id = (CASE WHEN m.sender_id = $1 THEN m.receiver_id ELSE m.sender_id END)
      WHERE m.sender_id = $1 OR m.receiver_id = $1
      ORDER BY other_id, m.created_at DESC;
    `;
    const result = await query(sql, [userId]);
    return result.rows;
  }

  static async markAsRead(receiverId: string, senderId: string) {
    const sql = `
      UPDATE messages SET is_read = TRUE 
      WHERE receiver_id = $1 AND sender_id = $2 AND is_read = FALSE
      RETURNING id;
    `;
    const result = await query(sql, [receiverId, senderId]);
    return result.rows.length;
  }

  static async deleteMessage(messageId: string, userId: string) {
    const sql = 'DELETE FROM messages WHERE id = $1 AND sender_id = $2 RETURNING id;';
    const result = await query(sql, [messageId, userId]);
    return result.rows.length > 0;
  }
}

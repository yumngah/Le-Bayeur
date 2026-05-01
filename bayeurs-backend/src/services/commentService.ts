import { query } from '../config/database.js';

export class CommentService {
  static async postComment(userId: string, propertyId: string, content: string, rating?: number, parentId?: string) {
    const sql = `
      INSERT INTO comments (user_id, property_id, content, rating, parent_id)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *;
    `;
    const result = await query(sql, [userId, propertyId, content, rating, parentId]);
    return result.rows[0];
  }

  static async getPropertyComments(propertyId: string, limit: number = 20, offset: number = 0) {
    const sql = `
      WITH RECURSIVE comment_tree AS (
        -- Root comments
        SELECT c.*, u.username, 0 as level
        FROM comments c
        JOIN users u ON c.user_id = u.id
        WHERE c.property_id = $1 AND c.parent_id IS NULL
        
        UNION ALL
        
        -- Replies
        SELECT c.*, u.username, ct.level + 1
        FROM comments c
        JOIN users u ON c.user_id = u.id
        JOIN comment_tree ct ON c.parent_id = ct.id
      )
      SELECT * FROM comment_tree
      ORDER BY created_at ASC
      LIMIT $2 OFFSET $3;
    `;
    const result = await query(sql, [propertyId, limit, offset]);
    return result.rows;
  }

  static async updateInteractions(commentId: string, type: 'like' | 'dislike') {
    const column = type === 'like' ? 'likes_count' : 'dislikes_count';
    const sql = `UPDATE comments SET ${column} = ${column} + 1 WHERE id = $1 RETURNING *;`;
    const result = await query(sql, [commentId]);
    return result.rows[0];
  }

  static async reportComment(commentId: string) {
    const sql = 'UPDATE comments SET is_reported = TRUE WHERE id = $1 RETURNING *;';
    const result = await query(sql, [commentId]);
    return result.rows[0];
  }

  static async deleteComment(commentId: string, userId: string) {
    const sql = 'DELETE FROM comments WHERE id = $1 AND user_id = $2 RETURNING id;';
    const result = await query(sql, [commentId, userId]);
    return result.rows.length > 0;
  }
}

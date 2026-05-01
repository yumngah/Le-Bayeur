import { Response, NextFunction } from 'express';
import { CommentService } from '../services/commentService.js';
import { AuthRequest } from '../middleware/auth.js';

export class CommentController {
  static async post(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { property_id, content, rating, parent_id } = req.body;
      if (!property_id || !content) return res.status(400).json({ message: 'Property ID and content are required' });

      const comment = await CommentService.postComment(req.user.id, property_id, content, rating, parent_id);
      res.status(201).json(comment);
    } catch (error) {
      next(error);
    }
  }

  static async getByProperty(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { propertyId } = req.params;
      const { limit, offset } = req.query;
      const comments = await CommentService.getPropertyComments(
        propertyId, 
        parseInt(limit as string || '20'), 
        parseInt(offset as string || '0')
      );
      res.status(200).json(comments);
    } catch (error) {
      next(error);
    }
  }

  static async interact(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { type } = req.body; // 'like' or 'dislike'
      if (!['like', 'dislike'].includes(type)) return res.status(400).json({ message: 'Invalid interaction type' });

      const comment = await CommentService.updateInteractions(id, type);
      res.status(200).json(comment);
    } catch (error) {
      next(error);
    }
  }

  static async report(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const comment = await CommentService.reportComment(id);
      res.status(200).json({ message: 'Comment reported successfully', id: comment.id });
    } catch (error) {
      next(error);
    }
  }

  static async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const success = await CommentService.deleteComment(id, req.user.id);
      if (!success) return res.status(404).json({ message: 'Comment not found or unauthorized' });
      res.status(200).json({ message: 'Comment deleted successfully' });
    } catch (error) {
      next(error);
    }
  }
}

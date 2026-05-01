import { Response, NextFunction } from 'express';
import { MessageService } from '../services/messageService.js';
import { AuthRequest } from '../middleware/auth.js';

export class MessageController {
  static async send(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { receiver_id, content, property_id } = req.body;
      if (!receiver_id || !content) return res.status(400).json({ message: 'Receiver and content are required' });

      const message = await MessageService.sendMessage(req.user.id, receiver_id, content, property_id);
      res.status(201).json(message);
    } catch (error) {
      next(error);
    }
  }

  static async getConversation(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { otherUserId } = req.params;
      const { limit, offset } = req.query;
      const messages = await MessageService.getConversation(
        req.user.id, 
        otherUserId, 
        parseInt(limit as string || '50'), 
        parseInt(offset as string || '0')
      );
      res.status(200).json(messages);
    } catch (error) {
      next(error);
    }
  }

  static async getChatList(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const chats = await MessageService.getConversationsList(req.user.id);
      res.status(200).json(chats);
    } catch (error) {
      next(error);
    }
  }

  static async markRead(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { senderId } = req.params;
      const count = await MessageService.markAsRead(req.user.id, senderId);
      res.status(200).json({ message: `Marked ${count} messages as read` });
    } catch (error) {
      next(error);
    }
  }

  static async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const success = await MessageService.deleteMessage(id, req.user.id);
      if (!success) return res.status(404).json({ message: 'Message not found or unauthorized' });
      res.status(200).json({ message: 'Message deleted successfully' });
    } catch (error) {
      next(error);
    }
  }
}

import { Response, NextFunction } from 'express';
import { PropertyService } from '../services/propertyService.js';
import { propertySchema, propertyUpdateSchema, propertyQuerySchema } from '../utils/validators.js';
import { AuthRequest } from '../middleware/auth.js';
import { logger } from '../server.js';

export class PropertyController {
  static async create(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { error } = propertySchema.validate(req.body);
      if (error) return res.status(400).json({ message: error.details[0].message });

      const property = await PropertyService.createProperty(req.user.id, req.body);
      res.status(201).json(property);
    } catch (error) {
      next(error);
    }
  }

  static async getAll(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { error, value } = propertyQuerySchema.validate(req.query);
      if (error) return res.status(400).json({ message: error.details[0].message });

      const properties = await PropertyService.getProperties(value);
      res.status(200).json(properties);
    } catch (error) {
      next(error);
    }
  }

  static async getById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const property = await PropertyService.getPropertyById(id);
      if (!property) return res.status(404).json({ message: 'Property not found' });

      // Increment views asynchronously
      PropertyService.incrementViews(id).catch(err => logger.error(`Failed to increment views for ${id}: ${err}`));

      res.status(200).json(property);
    } catch (error) {
      next(error);
    }
  }

  static async update(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { error } = propertyUpdateSchema.validate(req.body);
      if (error) return res.status(400).json({ message: error.details[0].message });

      const property = await PropertyService.updateProperty(id, req.user.id, req.body);
      if (!property) return res.status(404).json({ message: 'Property not found or unauthorized' });

      res.status(200).json(property);
    } catch (error) {
      next(error);
    }
  }

  static async delete(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const success = await PropertyService.deleteProperty(id, req.user.id);
      if (!success) return res.status(404).json({ message: 'Property not found or unauthorized' });

      res.status(200).json({ message: 'Property deleted successfully' });
    } catch (error) {
      next(error);
    }
  }

  static async uploadImages(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const files = req.files as Express.Multer.File[];

      if (!files || files.length === 0) {
        return res.status(400).json({ message: 'No images uploaded' });
      }

      const property = await PropertyService.getPropertyById(id);
      if (!property || property.owner_id !== req.user.id) {
        return res.status(404).json({ message: 'Property not found or unauthorized' });
      }

      const uploadedImages = [];
      for (const file of files) {
        const img = await PropertyService.addImage(id, `/uploads/${file.filename}`);
        uploadedImages.push(img);
      }

      res.status(201).json({
        message: 'Images uploaded successfully',
        images: uploadedImages
      });
    } catch (error) {
      next(error);
    }
  }

  static async uploadVerificationDoc(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const file = req.file;

      if (!file) {
        return res.status(400).json({ message: 'No document uploaded' });
      }

      const property = await PropertyService.getPropertyById(id);
      if (!property || property.owner_id !== req.user.id) {
        return res.status(404).json({ message: 'Property not found or unauthorized' });
      }

      const updatedProperty = await PropertyService.updateProperty(id, req.user.id, {
        verification_document_url: `/uploads/${file.filename}`,
        verification_status: 'PENDING'
      });

      res.status(200).json({
        message: 'Verification document uploaded successfully',
        property: updatedProperty
      });
    } catch (error) {
      next(error);
    }
  }
}

import { Router } from 'express';
import { PropertyController } from '../controllers/propertyController.js';
import { authenticate } from '../middleware/auth.js';
import { upload } from '../middleware/fileUpload.js';

const router = Router();

// Protected Property Routes
router.get('/', authenticate, PropertyController.getAll);
router.get('/:id', authenticate, PropertyController.getById);

// Protected Property Routes (Requires Authentication)
router.post('/', authenticate, PropertyController.create);
router.put('/:id', authenticate, PropertyController.update);
router.delete('/:id', authenticate, PropertyController.delete);

// Image & Document Uploads
router.post('/:id/images', authenticate, upload.array('images', 10), PropertyController.uploadImages);
router.post('/:id/verify-doc', authenticate, upload.single('document'), PropertyController.uploadVerificationDoc);

export default router;

import Joi from 'joi';

export const signupSchema = Joi.object({
  username: Joi.string().alphanum().min(3).max(30).required(),
  email: Joi.string().email().required(),
  phone_number: Joi.string().pattern(/^\+?[1-9]\d{1,14}$/).required(), // International format
  password: Joi.string()
    .min(8)
    .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])'))
    .required()
    .messages({
      'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
      'string.min': 'Password must be at least 8 characters long.'
    }),
  role: Joi.string().valid('TENANT', 'LANDLORD', 'OWNER', 'TECHNICIAN').required()
});

export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

export const verifySchema = Joi.object({
  user_id: Joi.string().uuid().required(),
  code: Joi.string().length(6).pattern(/^\d{6}$/).required()
});

export const propertySchema = Joi.object({
  name: Joi.string().min(3).max(100).required(),
  location: Joi.string().required(),
  latitude: Joi.number().min(-90).max(90),
  longitude: Joi.number().min(-180).max(180),
  type: Joi.string().valid('HOUSE', 'APARTMENT', 'STUDIO', 'ROOM', 'BUILDING').required(),
  status: Joi.string().valid('FOR_SALE', 'FOR_RENT', 'SOLD', 'OCCUPIED').required(),
  standing: Joi.string().valid('SIMPLE', 'STANDARD', 'LUXURY').required(),
  sale_price: Joi.number().min(0).when('status', { is: 'FOR_SALE', then: Joi.required() }),
  rent_price: Joi.number().min(0).when('status', { is: 'FOR_RENT', then: Joi.required() }),
  description: Joi.string().max(2000)
});

export const propertyUpdateSchema = propertySchema.fork(
  ['name', 'location', 'type', 'status', 'standing'], 
  (schema) => schema.optional()
);

export const messageSchema = Joi.object({
  receiver_id: Joi.string().uuid().required(),
  content: Joi.string().max(1000).required(),
  property_id: Joi.string().uuid().optional()
});

export const commentSchema = Joi.object({
  property_id: Joi.string().uuid().required(),
  content: Joi.string().min(2).max(500).required(),
  rating: Joi.number().min(1).max(5).optional(),
  parent_id: Joi.string().uuid().optional()
});

export const billSchema = Joi.object({
  type: Joi.string().valid('WATER', 'ELECTRICITY', 'SUBSCRIPTION', 'MAINTENANCE', 'OTHER').required(),
  amount: Joi.number().min(0).required(),
  due_date: Joi.date().iso().required()
});

export const technicianSchema = Joi.object({
  specialty: Joi.string().required(),
  bio: Joi.string().max(500).required()
});

export const maintenanceRequestSchema = Joi.object({
  property_id: Joi.string().uuid().required(),
  description: Joi.string().min(10).required(),
  urgency: Joi.string().valid('LOW', 'MEDIUM', 'HIGH', 'URGENT').required()
});

export const propertyQuerySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  status: Joi.string().valid('FOR_RENT', 'FOR_SALE', 'RENTED', 'SOLD').optional(),
  type: Joi.string().valid('APARTMENT', 'HOUSE', 'VILLA', 'STUDIO', 'OFFICE', 'LAND', 'OTHER').optional(),
  location: Joi.string().max(100).optional(),
  min_price: Joi.number().min(0).optional(),
  max_price: Joi.number().min(0).optional(),
  sortBy: Joi.string().valid('date', 'price', 'popularity').default('date'),
  order: Joi.string().valid('ASC', 'DESC').default('DESC')
});

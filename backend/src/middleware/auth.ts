import type { Request, Response, NextFunction } from 'express';
import { supabase } from '../config/supabase.js';
import { createError } from './errorHandler.js';

export interface AuthRequest extends Request {
  userId?: string;
  userRole?: string;
}

export async function requireAuth(
  req: AuthRequest,
  _res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return next(createError('Missing or invalid Authorization header', 401, 'UNAUTHORIZED'));
  }

  const token = authHeader.slice(7);
  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data.user) {
    return next(createError('Invalid or expired token', 401, 'UNAUTHORIZED'));
  }

  req.userId = data.user.id;
  req.userRole = data.user.user_metadata?.rol ?? 'turista';
  next();
}

export function requireRole(...roles: string[]) {
  return (req: AuthRequest, _res: Response, next: NextFunction): void => {
    if (!req.userRole || !roles.includes(req.userRole)) {
      return next(createError('Insufficient permissions', 403, 'FORBIDDEN'));
    }
    next();
  };
}

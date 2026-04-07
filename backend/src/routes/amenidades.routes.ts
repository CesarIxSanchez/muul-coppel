import { Router } from 'express';
import type { Request, Response } from 'express';
import { supabase } from '../config/supabase.js';
import { asyncHandler, createError } from '../middleware/errorHandler.js';
import { requireAuth, requireRole } from '../middleware/auth.js';
import type { AuthRequest } from '../middleware/auth.js';

const router = Router();

// GET /amenidades
router.get(
  '/',
  asyncHandler(async (_req: Request, res: Response) => {
    const { data, error } = await supabase.from('amenidades').select('*').order('nombre');
    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// POST /amenidades — admin only
router.post(
  '/',
  requireAuth,
  requireRole('admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('amenidades')
      .insert(req.body as { nombre: string; icono: string })
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'INSERT_ERROR');
    res.status(201).json(data);
  })
);

// DELETE /amenidades/:id — admin only
router.delete(
  '/:id',
  requireAuth,
  requireRole('admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { error } = await supabase.from('amenidades').delete().eq('id', req.params.id);
    if (error) throw createError(error.message, 400, 'DELETE_ERROR');
    res.status(204).send();
  })
);

export default router;

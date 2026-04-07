import { Router } from 'express';
import type { Request, Response } from 'express';
import { supabase } from '../config/supabase.js';
import { asyncHandler, createError } from '../middleware/errorHandler.js';
import { requireAuth, requireRole } from '../middleware/auth.js';
import type { AuthRequest } from '../middleware/auth.js';

// Colecciones = category/taxonomy for POIs and negocios
const router = Router();

// GET /colecciones — lista pública
router.get(
  '/',
  asyncHandler(async (req: Request, res: Response) => {
    const { tipo } = req.query as { tipo?: string };

    let query = supabase
      .from('colecciones')
      .select('*, pois(count), negocios(count)')
      .eq('activa', true)
      .order('nombre');

    if (tipo) query = query.eq('tipo', tipo);

    const { data, error } = await query;
    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// GET /colecciones/:id — con POIs y negocios incluidos
router.get(
  '/:id',
  asyncHandler(async (req: Request, res: Response) => {
    const { data, error } = await supabase
      .from('colecciones')
      .select('*, pois(*), negocios(*)')
      .eq('id', req.params.id)
      .eq('activa', true)
      .single();

    if (error) throw createError('Colección no encontrada', 404, 'NOT_FOUND');
    res.json(data);
  })
);

// POST /colecciones — admin only
router.post(
  '/',
  requireAuth,
  requireRole('admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('colecciones')
      .insert(req.body)
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'INSERT_ERROR');
    res.status(201).json(data);
  })
);

// PATCH /colecciones/:id — admin only
router.patch(
  '/:id',
  requireAuth,
  requireRole('admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('colecciones')
      .update(req.body as Record<string, unknown>)
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'UPDATE_ERROR');
    res.json(data);
  })
);

export default router;

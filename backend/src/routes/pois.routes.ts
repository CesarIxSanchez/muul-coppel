import { Router } from 'express';
import type { Request, Response } from 'express';
import { supabase } from '../config/supabase.js';
import { asyncHandler, createError } from '../middleware/errorHandler.js';
import { requireAuth, requireRole } from '../middleware/auth.js';
import type { AuthRequest } from '../middleware/auth.js';

const router = Router();

// GET /pois — con filtros por coleccion y búsqueda
router.get(
  '/',
  asyncHandler(async (req: Request, res: Response) => {
    const { coleccion_id, search, limit = '50', offset = '0' } = req.query as Record<string, string>;

    let query = supabase
      .from('pois')
      .select('*, colecciones(nombre, tipo)')
      .eq('activo', true)
      .order('nombre')
      .range(Number(offset), Number(offset) + Number(limit) - 1);

    if (coleccion_id) query = query.eq('coleccion_id', coleccion_id);
    if (search) query = query.ilike('nombre', `%${search}%`);

    const { data, error } = await query;
    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// GET /pois/:id
router.get(
  '/:id',
  asyncHandler(async (req: Request, res: Response) => {
    const { data, error } = await supabase
      .from('pois')
      .select('*, colecciones(nombre, tipo)')
      .eq('id', req.params.id)
      .eq('activo', true)
      .single();

    if (error) throw createError('POI no encontrado', 404, 'NOT_FOUND');
    res.json(data);
  })
);

// POST /pois — admin only
router.post(
  '/',
  requireAuth,
  requireRole('admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('pois')
      .insert(req.body)
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'INSERT_ERROR');
    res.status(201).json(data);
  })
);

// PATCH /pois/:id — admin only
router.patch(
  '/:id',
  requireAuth,
  requireRole('admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('pois')
      .update(req.body as Record<string, unknown>)
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'UPDATE_ERROR');
    res.json(data);
  })
);

// DELETE /pois/:id — soft delete
router.delete(
  '/:id',
  requireAuth,
  requireRole('admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { error } = await supabase
      .from('pois')
      .update({ activo: false })
      .eq('id', req.params.id);

    if (error) throw createError(error.message, 400, 'DELETE_ERROR');
    res.status(204).send();
  })
);

export default router;

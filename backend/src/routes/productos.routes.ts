import { Router } from 'express';
import type { Request, Response } from 'express';
import { supabase } from '../config/supabase.js';
import { asyncHandler, createError } from '../middleware/errorHandler.js';
import { requireAuth } from '../middleware/auth.js';
import type { AuthRequest } from '../middleware/auth.js';

const router = Router({ mergeParams: true });

// GET /negocios/:negocioId/productos
router.get(
  '/',
  asyncHandler(async (req: Request, res: Response) => {
    const { data, error } = await supabase
      .from('productos')
      .select('*')
      .eq('negocio_id', req.params.negocioId)
      .order('nombre');

    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// POST /negocios/:negocioId/productos
router.post(
  '/',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data: negocio } = await supabase
      .from('negocios')
      .select('propietario_id')
      .eq('id', req.params.negocioId)
      .single();

    if (
      !negocio ||
      ((negocio as { propietario_id: string }).propietario_id !== req.userId &&
        req.userRole !== 'admin')
    ) {
      throw createError('No tienes permiso', 403, 'FORBIDDEN');
    }

    const { data, error } = await supabase
      .from('productos')
      .insert({ ...(req.body as Record<string, unknown>), negocio_id: req.params.negocioId })
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'INSERT_ERROR');
    res.status(201).json(data);
  })
);

// PATCH /negocios/:negocioId/productos/:id
router.patch(
  '/:id',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data: negocio } = await supabase
      .from('negocios')
      .select('propietario_id')
      .eq('id', req.params.negocioId)
      .single();

    if (
      !negocio ||
      ((negocio as { propietario_id: string }).propietario_id !== req.userId &&
        req.userRole !== 'admin')
    ) {
      throw createError('No tienes permiso', 403, 'FORBIDDEN');
    }

    const { data, error } = await supabase
      .from('productos')
      .update(req.body as Record<string, unknown>)
      .eq('id', req.params.id)
      .eq('negocio_id', req.params.negocioId)
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'UPDATE_ERROR');
    res.json(data);
  })
);

// DELETE /negocios/:negocioId/productos/:id
router.delete(
  '/:id',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data: negocio } = await supabase
      .from('negocios')
      .select('propietario_id')
      .eq('id', req.params.negocioId)
      .single();

    if (
      !negocio ||
      ((negocio as { propietario_id: string }).propietario_id !== req.userId &&
        req.userRole !== 'admin')
    ) {
      throw createError('No tienes permiso', 403, 'FORBIDDEN');
    }

    const { error } = await supabase
      .from('productos')
      .delete()
      .eq('id', req.params.id)
      .eq('negocio_id', req.params.negocioId);

    if (error) throw createError(error.message, 400, 'DELETE_ERROR');
    res.status(204).send();
  })
);

export default router;

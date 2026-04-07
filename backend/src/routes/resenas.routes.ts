import { Router } from 'express';
import type { Request, Response } from 'express';
import { supabase } from '../config/supabase.js';
import { asyncHandler, createError } from '../middleware/errorHandler.js';
import { requireAuth } from '../middleware/auth.js';
import type { AuthRequest } from '../middleware/auth.js';

const router = Router();

// GET /resenas?negocio_id=
router.get(
  '/',
  asyncHandler(async (req: Request, res: Response) => {
    const { negocio_id, limit = '20', offset = '0' } = req.query as Record<string, string>;

    let query = supabase
      .from('resenas')
      .select('*, perfiles(nombre, foto_url)')
      .order('creado_en', { ascending: false })
      .range(Number(offset), Number(offset) + Number(limit) - 1);

    if (negocio_id) query = query.eq('negocio_id', negocio_id);

    const { data, error } = await query;
    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// POST /resenas
router.post(
  '/',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { calificacion, comentario, negocio_id } = req.body as {
      calificacion: number;
      comentario?: string;
      negocio_id: string;
    };

    if (!negocio_id) {
      throw createError('negocio_id es requerido', 400, 'VALIDATION_ERROR');
    }
    if (!calificacion || calificacion < 1 || calificacion > 5) {
      throw createError('calificacion debe ser entre 1 y 5', 400, 'VALIDATION_ERROR');
    }

    const { data, error } = await supabase
      .from('resenas')
      .insert({ calificacion, comentario, negocio_id, usuario_id: req.userId! })
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'INSERT_ERROR');
    res.status(201).json(data);
  })
);

// DELETE /resenas/:id — solo propietario o admin
router.delete(
  '/:id',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data: resena } = await supabase
      .from('resenas')
      .select('usuario_id')
      .eq('id', req.params.id)
      .single();

    if (!resena) throw createError('Reseña no encontrada', 404, 'NOT_FOUND');
    if (
      (resena as { usuario_id: string }).usuario_id !== req.userId &&
      req.userRole !== 'admin'
    ) {
      throw createError('No tienes permiso', 403, 'FORBIDDEN');
    }

    const { error } = await supabase.from('resenas').delete().eq('id', req.params.id);
    if (error) throw createError(error.message, 400, 'DELETE_ERROR');
    res.status(204).send();
  })
);

export default router;

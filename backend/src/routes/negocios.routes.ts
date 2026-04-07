import { Router } from 'express';
import type { Request, Response } from 'express';
import { supabase } from '../config/supabase.js';
import { asyncHandler, createError } from '../middleware/errorHandler.js';
import { requireAuth, requireRole } from '../middleware/auth.js';
import type { AuthRequest } from '../middleware/auth.js';

const router = Router();

// GET /negocios — directorio público con filtros
router.get(
  '/',
  asyncHandler(async (req: Request, res: Response) => {
    const { coleccion_id, search, limit = '50', offset = '0' } = req.query as Record<string, string>;

    let query = supabase
      .from('negocios')
      .select('*, colecciones(nombre, tipo), negocio_amenidades(amenidad_id, amenidades(*))')
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

// GET /negocios/mio — panel del propietario
router.get(
  '/mio',
  requireAuth,
  requireRole('empresa', 'admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('negocios')
      .select(
        '*, productos(*), negocio_amenidades(amenidad_id, amenidades(*)), negocio_stats(*)'
      )
      .eq('propietario_id', req.userId!);

    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// GET /negocios/:id
router.get(
  '/:id',
  asyncHandler(async (req: Request, res: Response) => {
    const { data, error } = await supabase
      .from('negocios')
      .select('*, colecciones(nombre, tipo), productos(*), negocio_amenidades(amenidad_id, amenidades(*))')
      .eq('id', req.params.id)
      .eq('activo', true)
      .single();

    if (error) throw createError('Negocio no encontrado', 404, 'NOT_FOUND');
    res.json(data);
  })
);

// POST /negocios — registro de negocio (empresa)
router.post(
  '/',
  requireAuth,
  requireRole('empresa', 'admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const body = { ...(req.body as Record<string, unknown>) };
    const amenidades = body.amenidades as string[] | undefined;
    delete body.amenidades;

    const { data: negocio, error } = await supabase
      .from('negocios')
      .insert({ ...body, propietario_id: req.userId!, activo: true, verificado: false, vistas: 0 })
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'INSERT_ERROR');

    if (amenidades?.length) {
      const rows = amenidades.map((amenidad_id) => ({ negocio_id: negocio.id, amenidad_id }));
      await supabase.from('negocio_amenidades').insert(rows);
    }

    res.status(201).json(negocio);
  })
);

// PATCH /negocios/:id — propietario o admin
router.patch(
  '/:id',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res: Response) => {
    if (req.userRole !== 'admin') {
      const { data: existing } = await supabase
        .from('negocios')
        .select('propietario_id')
        .eq('id', req.params.id)
        .single();

      if (!existing || (existing as { propietario_id: string }).propietario_id !== req.userId) {
        throw createError('No tienes permiso para editar este negocio', 403, 'FORBIDDEN');
      }
    }

    const body = { ...(req.body as Record<string, unknown>) };
    const amenidades = body.amenidades as string[] | undefined;
    delete body.amenidades;

    const { data, error } = await supabase
      .from('negocios')
      .update(body)
      .eq('id', req.params.id)
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'UPDATE_ERROR');

    if (amenidades !== undefined) {
      await supabase.from('negocio_amenidades').delete().eq('negocio_id', req.params.id);
      if (amenidades.length > 0) {
        const rows = amenidades.map((amenidad_id) => ({
          negocio_id: req.params.id,
          amenidad_id,
        }));
        await supabase.from('negocio_amenidades').insert(rows);
      }
    }

    res.json(data);
  })
);

// DELETE /negocios/:id — soft delete
router.delete(
  '/:id',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res: Response) => {
    if (req.userRole !== 'admin') {
      const { data: existing } = await supabase
        .from('negocios')
        .select('propietario_id')
        .eq('id', req.params.id)
        .single();

      if (!existing || (existing as { propietario_id: string }).propietario_id !== req.userId) {
        throw createError('No tienes permiso para eliminar este negocio', 403, 'FORBIDDEN');
      }
    }

    const { error } = await supabase
      .from('negocios')
      .update({ activo: false })
      .eq('id', req.params.id);

    if (error) throw createError(error.message, 400, 'DELETE_ERROR');
    res.status(204).send();
  })
);

// GET /negocios/:id/stats — panel propietario
router.get(
  '/:id/stats',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data: negocio } = await supabase
      .from('negocios')
      .select('propietario_id')
      .eq('id', req.params.id)
      .single();

    if (!negocio) throw createError('Negocio no encontrado', 404, 'NOT_FOUND');
    if (
      req.userRole !== 'admin' &&
      (negocio as { propietario_id: string }).propietario_id !== req.userId
    ) {
      throw createError('No tienes permiso', 403, 'FORBIDDEN');
    }

    const { data, error } = await supabase
      .from('negocio_stats')
      .select('*')
      .eq('negocio_id', req.params.id)
      .order('fecha', { ascending: false })
      .limit(30);

    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// POST /negocios/:id/vista — registrar vista (pública, anónima)
router.post(
  '/:id/vista',
  asyncHandler(async (req: Request, res: Response) => {
    const today = new Date().toISOString().slice(0, 10);
    await Promise.all([
      supabase.from('negocio_stats').upsert(
        { negocio_id: req.params.id, fecha: today, vistas: 1, clicks_ruta: 0, visitas_gps: 0 },
        { onConflict: 'negocio_id,fecha' }
      ),
      supabase.rpc('increment_vistas_negocio', { p_negocio_id: req.params.id }),
    ]);
    res.status(204).send();
  })
);

export default router;

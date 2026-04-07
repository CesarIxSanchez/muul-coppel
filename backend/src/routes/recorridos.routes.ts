import { Router } from 'express';
import type { Response } from 'express';
import { supabase } from '../config/supabase.js';
import { asyncHandler, createError } from '../middleware/errorHandler.js';
import { requireAuth } from '../middleware/auth.js';
import type { AuthRequest } from '../middleware/auth.js';

const router = Router();
router.use(requireAuth);

// GET /recorridos — historial del usuario
router.get(
  '/',
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('recorridos')
      .select('*, recorrido_nodos(*, pois(id, nombre, latitud, longitud))')
      .eq('usuario_id', req.userId!)
      .order('iniciado_en', { ascending: false });

    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// GET /recorridos/:id
router.get(
  '/:id',
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('recorridos')
      .select('*, recorrido_nodos(*, pois(*))')
      .eq('id', req.params.id)
      .eq('usuario_id', req.userId!)
      .single();

    if (error) throw createError('Recorrido no encontrado', 404, 'NOT_FOUND');
    res.json(data);
  })
);

// POST /recorridos — crear recorrido con nodos
// Body: { nodos: [{lugar_id, orden_visita, tiempo_estimado_seg?}], ...recorrido }
router.post(
  '/',
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { nodos, ...recorridoBody } = req.body as {
      nodos?: Array<{ lugar_id: string; orden_visita: number; tiempo_estimado_seg?: number }>;
      [key: string]: unknown;
    };

    const { data: recorrido, error } = await supabase
      .from('recorridos')
      .insert({ ...recorridoBody, usuario_id: req.userId!, completado: false })
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'INSERT_ERROR');

    if (nodos?.length) {
      const nodoRows = nodos.map((n) => ({ ...n, recorrido_id: (recorrido as { id: string }).id }));
      const { error: nodosErr } = await supabase.from('recorrido_nodos').insert(nodoRows);
      if (nodosErr) throw createError(nodosErr.message, 400, 'INSERT_ERROR');
    }

    res.status(201).json(recorrido);
  })
);

// PATCH /recorridos/:id — actualizar progreso
router.patch(
  '/:id',
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const allowed = ['pasos', 'distancia_m', 'duracion_seg', 'calorias_est', 'completado', 'finalizado_en'] as const;
    type AllowedKey = (typeof allowed)[number];
    const updates = Object.fromEntries(
      Object.entries(req.body as Record<string, unknown>).filter(([k]) =>
        (allowed as readonly string[]).includes(k)
      )
    ) as Partial<Record<AllowedKey, unknown>>;

    const { data, error } = await supabase
      .from('recorridos')
      .update(updates)
      .eq('id', req.params.id)
      .eq('usuario_id', req.userId!)
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'UPDATE_ERROR');

    // On completion update perfil stats
    if (updates.completado) {
      const rec = data as { pasos: number | null; distancia_m: number | null };
      await supabase.rpc('increment_perfil_stats', {
        p_usuario_id: req.userId!,
        p_pasos: rec.pasos ?? 0,
        p_distancia_m: rec.distancia_m ?? 0,
      });
    }

    res.json(data);
  })
);

// DELETE /recorridos/:id
router.delete(
  '/:id',
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { error } = await supabase
      .from('recorridos')
      .delete()
      .eq('id', req.params.id)
      .eq('usuario_id', req.userId!);

    if (error) throw createError(error.message, 400, 'DELETE_ERROR');
    res.status(204).send();
  })
);

export default router;

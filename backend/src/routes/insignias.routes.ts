import { Router } from 'express';
import type { Request, Response } from 'express';
import { supabase } from '../config/supabase.js';
import { asyncHandler, createError } from '../middleware/errorHandler.js';
import { requireAuth, requireRole } from '../middleware/auth.js';
import type { AuthRequest } from '../middleware/auth.js';

const router = Router();

// GET /insignias — catálogo completo (público)
router.get(
  '/',
  asyncHandler(async (_req: Request, res: Response) => {
    const { data, error } = await supabase
      .from('insignias')
      .select('*, colecciones(nombre, tipo)')
      .order('requisito_visitas');

    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// GET /insignias/usuario/:userId — insignias desbloqueadas
router.get(
  '/usuario/:userId',
  asyncHandler(async (req: Request, res: Response) => {
    const { data, error } = await supabase
      .from('usuario_insignias')
      .select('*, insignias(*)')
      .eq('usuario_id', req.params.userId)
      .order('obtenida_en', { ascending: false });

    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// POST /insignias/check — evaluar y desbloquear insignias para el usuario autenticado
router.post(
  '/check',
  requireAuth,
  asyncHandler(async (req: AuthRequest, res: Response) => {
    // Count verified visits for the user
    const { count, error: countErr } = await supabase
      .from('visitas')
      .select('id', { count: 'exact', head: true })
      .eq('usuario_id', req.userId!);

    if (countErr) throw createError(countErr.message, 500, 'DB_ERROR');
    const totalVisitas = count ?? 0;

    // Get already unlocked
    const { data: yaDesbloqueadas } = await supabase
      .from('usuario_insignias')
      .select('insignia_id')
      .eq('usuario_id', req.userId!);

    const desbloqueadasIds = (yaDesbloqueadas ?? []).map(
      (u: { insignia_id: string }) => u.insignia_id
    );

    // Find eligible insignias not yet unlocked
    let query = supabase
      .from('insignias')
      .select('*')
      .lte('requisito_visitas', totalVisitas);

    if (desbloqueadasIds.length > 0) {
      query = query.not('id', 'in', `(${desbloqueadasIds.join(',')})`);
    }

    const { data: nuevasInsignias, error: insigniasErr } = await query;
    if (insigniasErr) throw createError(insigniasErr.message, 500, 'DB_ERROR');

    if (!nuevasInsignias?.length) {
      return res.json({ nuevas: [] });
    }

    const rows = nuevasInsignias.map((i: { id: string }) => ({
      usuario_id: req.userId!,
      insignia_id: i.id,
    }));

    const { data: nuevas, error: insertErr } = await supabase
      .from('usuario_insignias')
      .insert(rows)
      .select('*, insignias(*)');

    if (insertErr) throw createError(insertErr.message, 500, 'INSERT_ERROR');
    res.json({ nuevas });
  })
);

// POST /insignias — admin: crear insignia
router.post(
  '/',
  requireAuth,
  requireRole('admin'),
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('insignias')
      .insert(req.body)
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'INSERT_ERROR');
    res.status(201).json(data);
  })
);

export default router;

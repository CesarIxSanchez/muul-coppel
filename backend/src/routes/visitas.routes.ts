import { Router } from 'express';
import type { Response } from 'express';
import { supabase } from '../config/supabase.js';
import { asyncHandler, createError } from '../middleware/errorHandler.js';
import { requireAuth } from '../middleware/auth.js';
import type { AuthRequest } from '../middleware/auth.js';

const VERIFICACION_RADIO_M = 100;

function haversineMetros(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371000;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

const router = Router();
router.use(requireAuth);

// GET /visitas — historial del usuario
router.get(
  '/',
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { data, error } = await supabase
      .from('visitas')
      .select('*')
      .eq('usuario_id', req.userId!)
      .order('visitado_en', { ascending: false });

    if (error) throw createError(error.message, 500, 'DB_ERROR');
    res.json(data);
  })
);

// POST /visitas — registrar visita con validación GPS opcional
// Body: { lugar_id, tipo_lugar: 'poi'|'negocio', coleccion_id?, latitud?, longitud? }
router.post(
  '/',
  asyncHandler(async (req: AuthRequest, res: Response) => {
    const { lugar_id, tipo_lugar, coleccion_id, latitud, longitud } = req.body as {
      lugar_id: string;
      tipo_lugar: 'poi' | 'negocio';
      coleccion_id?: string;
      latitud?: number;
      longitud?: number;
    };

    if (!lugar_id || !tipo_lugar) {
      throw createError('lugar_id y tipo_lugar son requeridos', 400, 'VALIDATION_ERROR');
    }
    if (!['poi', 'negocio'].includes(tipo_lugar)) {
      throw createError('tipo_lugar debe ser "poi" o "negocio"', 400, 'VALIDATION_ERROR');
    }

    // GPS proximity check when coordinates provided
    let verificada = false;
    if (latitud !== undefined && longitud !== undefined) {
      const table = tipo_lugar === 'poi' ? 'pois' : 'negocios';
      const { data: lugar } = await supabase
        .from(table)
        .select('latitud, longitud')
        .eq('id', lugar_id)
        .single();

      if (lugar) {
        const l = lugar as { latitud: number; longitud: number };
        verificada = haversineMetros(latitud, longitud, l.latitud, l.longitud) <= VERIFICACION_RADIO_M;
      }
    }

    const { data: visita, error } = await supabase
      .from('visitas')
      .insert({ lugar_id, tipo_lugar, coleccion_id, latitud, longitud, usuario_id: req.userId! })
      .select()
      .single();

    if (error) throw createError(error.message, 400, 'INSERT_ERROR');

    // Update negocio_stats if visiting a negocio and GPS-verified
    if (verificada && tipo_lugar === 'negocio') {
      const today = new Date().toISOString().slice(0, 10);
      await supabase.from('negocio_stats').upsert(
        { negocio_id: lugar_id, fecha: today, vistas: 0, clicks_ruta: 0, visitas_gps: 1 },
        { onConflict: 'negocio_id,fecha' }
      );
    }

    res.status(201).json({ ...(visita as object), verificada });
  })
);

export default router;

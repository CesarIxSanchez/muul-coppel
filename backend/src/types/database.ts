// ─── Entity interfaces ────────────────────────────────────────────────────────
// Generated from the actual Supabase public schema (MuulTests project).

export type Json = string | number | boolean | null | { [key: string]: Json } | Json[];

// Colecciones = categories/taxonomies for POIs and negocios
export interface Coleccion {
  id: string;
  nombre: string;
  descripcion: string | null;
  tipo: string;       // e.g. 'gastronomia', 'cultural', 'naturaleza'
  activa: boolean;
}

export interface Amenidad {
  id: string;
  nombre: string;
  icono: string;
}

export interface Insignia {
  id: string;
  coleccion_id: string | null;
  nombre: string;
  nivel: string;               // 'bronce' | 'plata' | 'oro' | 'platino'
  requisito_visitas: number;
  emoji: string;
}

export interface NegocioAmenidad {
  negocio_id: string;
  amenidad_id: string;
}

export interface NegocioStats {
  id: string;
  negocio_id: string;
  fecha: string;
  vistas: number;
  clicks_ruta: number;
  visitas_gps: number;
}

export interface Negocio {
  id: string;
  propietario_id: string;
  nombre: string;
  descripcion: string | null;
  coleccion_id: string | null;
  latitud: number;
  longitud: number;
  horario: Json | null;
  foto_url: string | null;
  activo: boolean;
  vistas: number;
  creado_en: string;
  verificado: boolean;
  calificacion_promedio: number | null;
  total_resenas: number;
}

export interface Perfil {
  id: string;           // same as auth.users.id
  nombre: string;
  tipo: 'turista' | 'empresa' | 'admin';
  foto_url: string | null;
  idioma: 'es' | 'en' | 'zh' | 'pt';
  pasos_total: number;
  distancia_km: number;
  creado_en: string;
}

export interface Poi {
  id: string;
  nombre: string;
  descripcion: string | null;
  coleccion_id: string | null;
  latitud: number;
  longitud: number;
  horario: Json | null;
  precio_entrada: number | null;
  contexto_ia: string | null;
  activo: boolean;
}

export interface Producto {
  id: string;
  negocio_id: string;
  nombre: string;
  descripcion: string | null;
  precio: number | null;
  foto_url: string | null;
}

export interface RecorridoNodo {
  id: string;
  recorrido_id: string;
  lugar_id: string;          // poi or negocio id
  orden_visita: number;
  tiempo_estimado_seg: number | null;
}

export interface Recorrido {
  id: string;
  usuario_id: string;
  pasos: number | null;
  distancia_m: number | null;
  duracion_seg: number | null;
  calorias_est: number | null;
  completado: boolean;
  iniciado_en: string;
  finalizado_en: string | null;
}

export interface Resena {
  id: string;
  negocio_id: string;
  usuario_id: string;
  calificacion: number;
  comentario: string | null;
  creado_en: string;
}

export interface UsuarioInsignia {
  id: string;
  usuario_id: string;
  insignia_id: string;
  obtenida_en: string;
}

export interface Visita {
  id: string;
  usuario_id: string;
  lugar_id: string;
  tipo_lugar: 'poi' | 'negocio';
  coleccion_id: string | null;
  latitud: number | null;
  longitud: number | null;
  visitado_en: string;
}

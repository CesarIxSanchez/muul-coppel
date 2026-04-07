import { Router } from 'express';
import authRoutes from './auth.routes.js';
import perfilesRoutes from './perfiles.routes.js';
import poisRoutes from './pois.routes.js';
import negociosRoutes from './negocios.routes.js';
import productosRoutes from './productos.routes.js';
import amenidadesRoutes from './amenidades.routes.js';
import recorridosRoutes from './recorridos.routes.js';
import insigniasRoutes from './insignias.routes.js';
import resenasRoutes from './resenas.routes.js';
import visitasRoutes from './visitas.routes.js';
import coleccionesRoutes from './colecciones.routes.js';

const router = Router();

router.use('/auth', authRoutes);
router.use('/perfiles', perfilesRoutes);
router.use('/pois', poisRoutes);
router.use('/negocios', negociosRoutes);
router.use('/negocios/:negocioId/productos', productosRoutes);
router.use('/amenidades', amenidadesRoutes);
router.use('/recorridos', recorridosRoutes);
router.use('/insignias', insigniasRoutes);
router.use('/resenas', resenasRoutes);
router.use('/visitas', visitasRoutes);
router.use('/colecciones', coleccionesRoutes);

export default router;

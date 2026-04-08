4. Descripción Técnica de la Solución

4.1 Arquitectura General
La arquitectura de Muul sigue un modelo de tres capas con separación clara de responsabilidades:
• Capa de Presentación: Aplicación web Next.js 14 con TypeScript, renderizado híbrido (SSR
+ CSR), Tailwind CSS v4 para estilos, y componentes React organizados por dominio
funcional.
• Capa de Lógica y APIs: API Routes de Next.js como backend serverless para el chatbot,
cálculo de rutas, consulta de lugares y autenticación. Sin servidor propio requerido en la
versión actual.
• Capa de Datos: Supabase (PostgreSQL) para datos relacionales, autenticación de usuarios
y almacenamiento de archivos. Redis implícito vía Supabase para sesiones activas.

4.2 Stack Tecnológico
Área Tecnología Justificación
Frontend Next.js 14 + TypeScript Framework React con SSR/CSR híbrido, App
Router y API Routes integradas. Ideal para SEO y
velocidad de carga.

Estilos Tailwind CSS v4 Sistema de diseño utility-first con variables CSS
dinámicas para el sistema de temas por evento.

Mapas y Rutas Mapbox GL JS + react-
map-gl v8

Mapa interactivo en modo oscuro (dark-v11),
Directions API para rutas reales con tiempos de
tránsito y Places API para POIs externos.

Base de Datos Supabase
(PostgreSQL)

Base de datos relacional en la nube con
autenticación integrada, triggers automáticos y
Row Level Security.

IA / Chatbot OpenRouter API
(gemma-3-4b-it)

Agente conversacional multilingüe inicializado con
contexto del POI activo. Sin necesidad de
entrenar modelos propios.

Autenticación Supabase Auth + JWT Login con email/contraseña, tokens de corta
duración, bloqueo automático tras 5 intentos
fallidos.

i18n Sistema propio
(IdiomaProvider)

Contexto React con carga dinámica de
traducciones en JSON. Cambio de idioma
instantáneo sin reinicio de la app.

Temas TemaProvider + CSS

Variables

Sistema de temas dinámico que actualiza
variables CSS globales en tiempo real

Área Tecnología Justificación
Deploy Vercel Deploy automático desde GitHub con CDN global,
dominio HTTPS y preview deployments por rama.

4.3 Módulos Implementados
Módulo Funcionalidad Estado
Autenticación Registro de turistas y empresas, login con JWT, bloqueo

por intentos, modo invitado


Mapa Interactivo Mapa Mapbox dark-v11 con POIs de Supabase + Mapbox
Places, filtros por categoría, marcadores animados (pop)


Rutas Optimizadas Cálculo TSP, hasta 3 rutas alternativas, itinerario con
tiempos, indicaciones paso a paso multilingüe


Chatbot IA Preguntas predefinidas por categoría (5 por tipo),
respuestas contextuales en 4 idiomas vía OpenRouter


Perfiles Perfil turista (estadísticas) y empresa (panel de gestión),

edición de nombre e idioma


Directorio Registro gratuito de negocios, validación GPS, productos,

horario, filtros y búsqueda


i18n 4 idiomas completos: ES, EN, ZH, PT en toda la interfaz
incluyendo el chatbot y las indicaciones de ruta


Temas de Eventos 4 temas: Muul 2026, Día de Muertos, Primavera,

Navidad con cambio dinámico de paleta


Sistema Insignias Tablas en BD, 13 insignias en 4 niveles, lógica de

desbloqueo por visitas verificadas


Contador de Pasos Pedómetro nativo del dispositivo, registro de recorridos,

calorías estimadas


Panel Negocios Estadísticas de vistas, visitas verificadas y presencia en

rutas para propietarios


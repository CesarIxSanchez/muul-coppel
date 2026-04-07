# Documentación de Endpoints de la API - Plataforma Muul

**URL Base:** `http://localhost:8080/api/v1`  
**Versión:** 1.0.0  
**Última Actualización:** 2026-03-31

---

## Tabla de Contenidos

1. [Autenticación](#autenticación)
2. [Perfiles](#perfiles)
3. [Puntos de Interés (POIs)](#puntos-de-interés-pois)
4. [Negocios](#negocios)
5. [Productos](#productos)
6. [Amenidades](#amenidades)
7. [Rutas e Itinerarios (Recorridos)](#rutas-e-itinerarios-recorridos)
8. [Colecciones](#colecciones)
9. [Insignias](#insignias)
10. [Reseñas](#reseñas)
11. [Visitas](#visitas)

---

## Autenticación

### POST /auth/register

Registrar una nueva cuenta de usuario.

**Autenticación:** No requerida

**Cuerpo de la Solicitud:**
```json
{
  "email": "usuario@example.com",
  "password": "contraseñaSegura123",
  "nombre": "Juan Martinez",
  "tipo": "turista",
  "idioma": "es"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|----------|-------------|
| email | string | Sí | Correo del usuario |
| password | string | Sí | Contraseña de la cuenta |
| nombre | string | Sí | Nombre completo |
| tipo | string | No | Tipo de usuario: `turista`, `empresa`, `admin` (por defecto: `turista`) |
| idioma | string | No | Preferencia de idioma: `es`, `en`, `fr` (por defecto: `es`) |

**Respuesta (201 Creado):**
```json
{
  "message": "Usuario registrado exitosamente",
  "userId": "uuid-string"
}
```

**Respuestas de Error:**
- `400` VALIDATION_ERROR: Faltan campos requeridos
- `400` AUTH_ERROR: El correo ya existe u otro problema de autenticación
- `500` PROFILE_CREATE_ERROR: Falló la creación del perfil de usuario

---

### POST /auth/login

Autenticar usuario y recibir tokens JWT.

**Autenticación:** No requerida

**Cuerpo de la Solicitud:**
```json
{
  "email": "usuario@example.com",
  "password": "contraseñaSegura123"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|----------|-------------|
| email | string | Sí | Correo del usuario |
| password | string | Sí | Contraseña de la cuenta |

**Respuesta (200 OK):**
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "valor_refresh_token",
  "expires_in": 3600,
  "user": {
    "id": "uuid-string",
    "email": "usuario@example.com",
    "tipo": "turista",
    "idioma": "es"
  }
}
```

**Respuestas de Error:**
- `400` VALIDATION_ERROR: Faltan email o password
- `401` AUTH_ERROR: Credenciales inválidas
- `400` AUTH_ERROR: Otro fallo de autenticación

---

### POST /auth/refresh

Actualizar un token de acceso expirado usando un refresh token.

**Autenticación:** No requerida

**Cuerpo de la Solicitud:**
```json
{
  "refresh_token": "valor_refresh_token"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|----------|-------------|
| refresh_token | string | Sí | Token de refresco válido |

**Respuesta (200 OK):**
```json
{
  "access_token": "nuevo_eyJhbGc...",
  "refresh_token": "nuevo_valor_refresh_token",
  "expires_in": 3600
}
```

**Respuestas de Error:**
- `400` VALIDATION_ERROR: Falta el refresh_token
- `401` UNAUTHORIZED: Refresh token inválido o expirado

---

### POST /auth/logout

Cerrar sesión del usuario autenticado actual e invalidar la sesión.

**Autenticación:** Requerida (token Bearer)

**Cuerpo de la Solicitud:** Vacío

**Respuesta (200 OK):**
```json
{
  "message": "Sesión cerrada"
}
```

**Respuestas de Error:**
- `401` UNAUTHORIZED: Token inválido o ausente

---

### GET /auth/me

Obtener la información del perfil del usuario autenticado actual.

**Autenticación:** Requerida (token Bearer)

**Respuesta (200 OK):**
```json
{
  "id": "uuid-string",
  "nombre": "Juan Martinez",
  "tipo": "turista",
  "idioma": "es",
  "pasos_total": 5234,
  "distancia_km": 12.5,
  "foto_url": null,
  "creado_en": "2026-03-20T10:30:00Z"
}
```

**Respuestas de Error:**
- `401` UNAUTHORIZED: Token ausente o inválido
- `404` NOT_FOUND: Perfil de usuario no encontrado

---

## Perfiles

Todos los endpoints de perfil excepto GET /:id requieren autenticación.

### GET /perfiles/me

Obtener el perfil completo del usuario autenticado actual.

**Autenticación:** Requerida (token Bearer)

**Respuesta (200 OK):**
```json
{
  "id": "uuid-string",
  "nombre": "Juan Martinez",
  "tipo": "turista",
  "idioma": "es",
  "foto_url": "https://...",
  "pasos_total": 5234,
  "distancia_km": 12.5,
  "creado_en": "2026-03-20T10:30:00Z"
}
```

---

### PATCH /perfiles/me

Actualizar el perfil del usuario actual (solo campos permitidos: nombre, foto_url, idioma).

**Autenticación:** Requerida (token Bearer)

**Cuerpo de la Solicitud:**
```json
{
  "nombre": "Juan Carlos Martinez",
  "foto_url": "https://example.com/photo.jpg",
  "idioma": "en"
}
```

| Campo | Tipo | Requerido | Notas |
|-------|------|----------|-------|
| nombre | string | No | Nombre de usuario |
| foto_url | string | No | URL de la foto de perfil |
| idioma | string | No | Idioma: `es`, `en`, `fr` |

**Respuesta (200 OK):**
```json
{
  "id": "uuid-string",
  "nombre": "Juan Carlos Martinez",
  "tipo": "turista",
  "idioma": "en",
  "foto_url": "https://example.com/photo.jpg",
  "pasos_total": 5234,
  "distancia_km": 12.5,
  "creado_en": "2026-03-20T10:30:00Z"
}
```

**Respuestas de Error:**
- `400` VALIDATION_ERROR: No hay campos válidos para actualizar
- `400` UPDATE_ERROR: Fallo en la actualización de la base de datos

---

### GET /perfiles/me/stats

Obtener las estadísticas de gamificación del usuario actual (pasos, distancia, insignias).

**Autenticación:** Requerida (token Bearer)

**Respuesta (200 OK):**
```json
{
  "pasos_total": 5234,
  "distancia_km": 12.5,
  "insignias": [
    {
      "usuario_id": "uuid-string",
      "insignia_id": "uuid-string",
      "obtenida_en": "2026-03-25T14:20:00Z",
      "insignias": {
        "id": "uuid-string",
        "nombre": "Explorador Urbano",
        "descripcion": "Visita 10 POIs",
        "icono": "badge_explorer",
        "requisito_visitas": 10,
        "coleccion_id": "uuid-string"
      }
    }
  ]
}
```

---

### GET /perfiles/:id

Obtener información pública del perfil de cualquier usuario por ID.

**Autenticación:** Requerida (token Bearer)

**Respuesta (200 OK):**
```json
{
  "id": "uuid-string",
  "nombre": "Juan Martinez",
  "foto_url": "https://...",
  "tipo": "turista",
  "pasos_total": 5234,
  "distancia_km": 12.5,
  "creado_en": "2026-03-20T10:30:00Z"
}
```

**Respuestas de Error:**
- `404` NOT_FOUND: Perfil de usuario no encontrado

---

## Puntos de Interés (POIs)

### GET /pois

Listar todos los POIs activos con filtrado opcional.

**Autenticación:** No requerida

**Parámetros de Query:**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| coleccion_id | string | Filtrar por ID de colección |
| search | string | Buscar por nombre del POI (insensible a mayúsculas) |
| limit | number | Resultados por página (por defecto: 50) |
| offset | number | Desplazamiento de paginación (por defecto: 0) |

**Ejemplo:** `GET /pois?coleccion_id=col123&search=plaza&limit=20&offset=0`

**Respuesta (200 OK):**
```json
[
  {
    "id": "uuid-string",
    "nombre": "Plaza Mayor",
    "descripcion": "Plaza histórica principal",
    "latitud": 19.4326,
    "longitud": -99.1332,
    "foto_url": "https://...",
    "coleccion_id": "uuid-string",
    "activo": true,
    "creado_en": "2026-03-01T00:00:00Z",
    "colecciones": {
      "nombre": "Plazas Públicas",
      "tipo": "landmark"
    }
  }
]
```

---

### GET /pois/:id

Obtener información detallada sobre un POI específico.

**Autenticación:** No requerida

**Respuesta (200 OK):**
```json
{
  "id": "uuid-string",
  "nombre": "Plaza Mayor",
  "descripcion": "Plaza histórica principal",
  "latitud": 19.4326,
  "longitud": -99.1332,
  "foto_url": "https://...",
  "coleccion_id": "uuid-string",
  "activo": true,
  "creado_en": "2026-03-01T00:00:00Z",
  "colecciones": {
    "nombre": "Plazas Públicas",
    "tipo": "landmark"
  }
}
```

**Respuestas de Error:**
- `404` NOT_FOUND: POI no encontrado o inactivo

---

### POST /pois

Crear un nuevo POI (solo admin).

**Autenticación:** Requerida - Solo rol Admin

**Cuerpo de la Solicitud:**
```json
{
  "nombre": "Nuevo Punto de Interés",
  "descripcion": "Un hermoso punto de interés",
  "latitud": 19.4326,
  "longitud": -99.1332,
  "foto_url": "https://example.com/photo.jpg",
  "coleccion_id": "uuid-string"
}
```

**Respuesta (201 Creado):**
```json
{
  "id": "nuevo-uuid",
  "nombre": "Nuevo Punto de Interés",
  "descripcion": "Un hermoso punto de interés",
  "latitud": 19.4326,
  "longitud": -99.1332,
  "foto_url": "https://example.com/photo.jpg",
  "coleccion_id": "uuid-string",
  "activo": true,
  "creado_en": "2026-03-31T12:00:00Z"
}
```

**Respuestas de Error:**
- `401` UNAUTHORIZED: No autenticado
- `403` FORBIDDEN: El usuario no es admin
- `400` INSERT_ERROR: Error de validación

---

### PATCH /pois/:id

Actualizar detalles del POI (solo admin).

**Autenticación:** Requerida - Solo rol Admin

**Cuerpo de la Solicitud:**
```json
{
  "nombre": "Nombre del Punto Actualizado",
  "descripcion": "Descripción actualizada",
  "foto_url": "https://example.com/new-photo.jpg"
}
```

**Respuesta (200 OK):** Objeto POI actualizado

**Respuestas de Error:**
- `401` UNAUTHORIZED: No autenticado
- `403` FORBIDDEN: El usuario no es admin
- `400` UPDATE_ERROR: Fallo en la actualización de la base de datos

---

### DELETE /pois/:id

Eliminar de manera suave un POI (solo admin). Establece `activo` a false.

**Autenticación:** Requerida - Solo rol Admin

**Respuesta (204 Sin Contenido)**

**Respuestas de Error:**
- `401` UNAUTHORIZED: No autenticado
- `403` FORBIDDEN: El usuario no es admin
- `400` DELETE_ERROR: Fallo en la operación de la base de datos

---

## Negocios

### GET /negocios

Listar todos los negocios activos (directorio público).

**Autenticación:** No requerida

**Parámetros de Query:**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| coleccion_id | string | Filtrar por colección/categoría |
| search | string | Buscar por nombre del negocio |
| limit | number | Resultados por página (por defecto: 50) |
| offset | number | Desplazamiento de paginación (por defecto: 0) |

**Respuesta (200 OK):**
```json
[
  {
    "id": "negocio-uuid",
    "nombre": "Restaurante El Sabor",
    "descripcion": "Cocina tradicional mexicana",
    "latitud": 19.4326,
    "longitud": -99.1332,
    "direccion": "Calle Principal 123",
    "telefonos": "5551234567",
    "horario": "08:00-22:00",
    "sitio_web": "https://example.com",
    "instagram": "@elsabor",
    "coleccion_id": "uuid-string",
    "propietario_id": "owner-uuid",
    "vistas": 1523,
    "activo": true,
    "verificado": true,
    "colecciones": {
      "nombre": "Restaurantes",
      "tipo": "dining"
    },
    "negocio_amenidades": [
      {
        "amenidad_id": "wifi-uuid",
        "amenidades": {
          "id": "wifi-uuid",
          "nombre": "WiFi Gratis",
          "icono": "wifi"
        }
      }
    ]
  }
]
```

---

### GET /negocios/mio

Obtener el panel de negocios del usuario actual (solo propietario de negocio).

**Autenticación:** Requerida - Rol: empresa o admin

**Respuesta (200 OK):**
```json
[
  {
    "id": "negocio-uuid",
    "nombre": "Mi Restaurante",
    "... todos los campos del negocio ...",
    "productos": [ /* arreglo de productos */ ],
    "negocio_amenidades": [ /* arreglo de amenidades */ ],
    "negocio_stats": [ /* arreglo de estadísticas */ ]
  }
]
```

---

### GET /negocios/:id

Obtener información detallada sobre un negocio específico.

**Autenticación:** No requerida

**Respuesta (200 OK):**
```json
{
  "id": "negocio-uuid",
  "nombre": "Restaurante El Sabor",
  "descripcion": "Cocina tradicional mexicana",
  "latitud": 19.4326,
  "longitud": -99.1332,
  "direccion": "Calle Principal 123",
  "telefonos": "5551234567",
  "horario": "08:00-22:00",
  "sitio_web": "https://example.com",
  "instagram": "@elsabor",
  "coleccion_id": "uuid-string",
  "propietario_id": "owner-uuid",
  "vistas": 1523,
  "activo": true,
  "verificado": true,
  "productos": [ /* arreglo de productos */ ],
  "negocio_amenidades": [ /* arreglo de amenidades */ ],
  "colecciones": {
    "nombre": "Restaurantes",
    "tipo": "dining"
  }
}
```

**Respuestas de Error:**
- `404` NOT_FOUND: Negocio no encontrado o inactivo

---

### POST /negocios

Registrar un nuevo negocio (propietario de negocio o admin).

**Autenticación:** Requerida - Rol: empresa o admin

**Cuerpo de la Solicitud:**
```json
{
  "nombre": "Mi Nuevo Restaurante",
  "descripcion": "Cocina local increíble",
  "latitud": 19.4326,
  "longitud": -99.1332,
  "direccion": "Calle Principal 456",
  "telefonos": "5559876543",
  "horario": "10:00-23:00",
  "sitio_web": "https://mirestaurante.com",
  "instagram": "@mirestaurante",
  "coleccion_id": "uuid-string",
  "amenidades": ["amenidad-uuid-1", "amenidad-uuid-2"]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|----------|-------------|
| nombre | string | Sí | Nombre del negocio |
| descripcion | string | No | Descripción del negocio |
| latitud | number | Sí | Latitud GPS |
| longitud | number | Sí | Longitud GPS |
| direccion | string | No | Dirección física |
| telefonos | string | No | Número(s) de teléfono |
| horario | string | No | Horario de operación |
| sitio_web | string | No | URL del sitio web |
| instagram | string | No | Usuario de Instagram |
| coleccion_id | string | No | Categoría del negocio |
| amenidades | string[] | No | Arreglo de IDs de amenidades |

**Respuesta (201 Creado):** Objeto negocio creado

**Respuestas de Error:**
- `401` UNAUTHORIZED: No autenticado
- `403` FORBIDDEN: El usuario no es empresa/admin
- `400` INSERT_ERROR: Error de validación

---

### PATCH /negocios/:id

Actualizar información del negocio (propietario o admin).

**Autenticación:** Requerida

**Autorización:** El usuario debe ser propietario del negocio o admin

**Cuerpo de la Solicitud:** Igual a POST /negocios (actualizaciones parciales permitidas)

**Respuesta (200 OK):** Objeto negocio actualizado

**Respuestas de Error:**
- `401` UNAUTHORIZED: No autenticado
- `403` FORBIDDEN: No es propietario del negocio o admin
- `400` UPDATE_ERROR: Fallo en la actualización de la base de datos

---

### DELETE /negocios/:id

Eliminar de manera suave un negocio (propietario o admin).

**Autenticación:** Requerida

**Autorización:** El usuario debe ser propietario del negocio o admin

**Respuesta (204 Sin Contenido)**

**Respuestas de Error:**
- `401` UNAUTHORIZED: No autenticado
- `403` FORBIDDEN: No es propietario del negocio o admin

---

### GET /negocios/:id/stats

Obtener panel de análisis del negocio (solo propietario o admin).

**Autenticación:** Requerida

**Autorización:** Propietario del negocio o admin

**Respuesta (200 OK):**
```json
[
  {
    "negocio_id": "uuid-string",
    "fecha": "2026-03-31",
    "vistas": 45,
    "clicks_ruta": 12,
    "visitas_gps": 8,
    "creado_en": "2026-03-31T00:00:00Z"
  }
]
```

Devuelve últimos 30 días de estadísticas ordenadas por fecha descendente.

**Respuestas de Error:**
- `403` FORBIDDEN: No autorizado para ver estadísticas
- `404` NOT_FOUND: Negocio no encontrado

---

### POST /negocios/:id/vista

Registrar una vista de negocio (público, sin autenticación requerida).

**Autenticación:** No requerida

**Cuerpo de la Solicitud:** Vacío

**Respuesta (204 Sin Contenido)**

**Efectos Secundarios:**
- Incrementa el contador de vistas diarias en negocio_stats
- Incrementa el campo vistas en la tabla negocios

---

## Productos

Todos los endpoints de producto están anidados bajo un negocio: `/negocios/:negocioId/productos`

### GET /negocios/:negocioId/productos

Listar todos los productos de un negocio.

**Autenticación:** No requerida

**Respuesta (200 OK):**
```json
[
  {
    "id": "producto-uuid",
    "negocio_id": "negocio-uuid",
    "nombre": "Tacos al Pastor",
    "descripcion": "Tacos deliciosos de cerdo",
    "precio": 45.50,
    "foto_url": "https://...",
    "activo": true,
    "creado_en": "2026-03-25T10:00:00Z"
  }
]
```

---

### POST /negocios/:negocioId/productos

Crear un nuevo producto (propietario del negocio o admin).

**Autenticación:** Requerida

**Autorización:** Propietario del negocio o admin

**Cuerpo de la Solicitud:**
```json
{
  "nombre": "Tacos al Pastor",
  "descripcion": "Tacos deliciosos de cerdo",
  "precio": 45.50,
  "foto_url": "https://example.com/photo.jpg"
}
```

**Respuesta (201 Creado):** Objeto producto creado

---

### PATCH /negocios/:negocioId/productos/:id

Actualizar información del producto (propietario o admin).

**Autenticación:** Requerida

**Autorización:** Propietario del negocio o admin

**Cuerpo de la Solicitud:** Campos del producto a actualizar

**Respuesta (200 OK):** Objeto producto actualizado

---

### DELETE /negocios/:negocioId/productos/:id

Eliminar un producto (propietario o admin).

**Autenticación:** Requerida

**Autorización:** Propietario del negocio o admin

**Respuesta (204 Sin Contenido)**

---

## Amenidades

### GET /amenidades

Listar todas las amenidades disponibles (público).

**Autenticación:** No requerida

**Respuesta (200 OK):**
```json
[
  {
    "id": "amenidad-uuid",
    "nombre": "WiFi Gratis",
    "icono": "wifi"
  },
  {
    "id": "amenidad-uuid",
    "nombre": "Estacionamiento",
    "icono": "parking"
  }
]
```

---

### POST /amenidades

Crear una nueva amenidad (solo admin).

**Autenticación:** Requerida - Solo rol Admin

**Cuerpo de la Solicitud:**
```json
{
  "nombre": "Terraza",
  "icono": "outdoor_seating"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|----------|-------------|
| nombre | string | Sí | Nombre de la amenidad |
| icono | string | Sí | Identificador del icono |

**Respuesta (201 Creado):** Objeto amenidad creado

---

### DELETE /amenidades/:id

Eliminar una amenidad (solo admin).

**Autenticación:** Requerida - Solo rol Admin

**Respuesta (204 Sin Contenido)**

---

## Rutas e Itinerarios (Recorridos)

Todos los endpoints requieren autenticación.

### GET /recorridos

Obtener el historial de rutas del usuario (más recientes primero).

**Autenticación:** Requerida (token Bearer)

**Respuesta (200 OK):**
```json
[
  {
    "id": "recorrido-uuid",
    "usuario_id": "user-uuid",
    "nombre": "Recorrido Centro",
    "iniciado_en": "2026-03-30T14:00:00Z",
    "finalizado_en": "2026-03-30T16:30:00Z",
    "pasos": 8234,
    "distancia_m": 5420,
    "duracion_seg": 9000,
    "calorias_est": 450,
    "completado": true,
    "recorrido_nodos": [
      {
        "lugar_id": "poi-uuid",
        "orden_visita": 1,
        "tiempo_estimado_seg": 600,
        "pois": {
          "id": "poi-uuid",
          "nombre": "Plaza Mayor",
          "latitud": 19.4326,
          "longitud": -99.1332
        }
      }
    ]
  }
]
```

---

### GET /recorridos/:id

Obtener información detallada sobre una ruta específica.

**Autenticación:** Requerida - Debe ser dueño de la ruta

**Respuesta (200 OK):** Objeto ruta detallado con todos los nodos e información del POI

**Respuestas de Error:**
- `404` NOT_FOUND: Ruta no encontrada o no es propiedad del usuario

---

### POST /recorridos

Crear una nueva ruta con puntos de referencia.

**Autenticación:** Requerida (token Bearer)

**Cuerpo de la Solicitud:**
```json
{
  "nombre": "Recorrido Centro",
  "nodos": [
    {
      "lugar_id": "poi-uuid-1",
      "orden_visita": 1,
      "tiempo_estimado_seg": 600
    },
    {
      "lugar_id": "poi-uuid-2",
      "orden_visita": 2,
      "tiempo_estimado_seg": 900
    }
  ]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|----------|-------------|
| nombre | string | No | Nombre de la ruta |
| nodos | array | No | Arreglo de puntos de referencia |
| nodos[].lugar_id | string | Sí | ID del POI o negocio |
| nodos[].orden_visita | number | Sí | Orden de visita |
| nodos[].tiempo_estimado_seg | number | No | Tiempo estimado en segundos |

**Respuesta (201 Creado):** Objeto ruta creado

**Respuestas de Error:**
- `400` INSERT_ERROR: Datos inválidos

---

### PATCH /recorridos/:id

Actualizar progreso de la ruta (pasos, distancia, duración, calorías, finalización).

**Autenticación:** Requerida - Debe ser dueño de la ruta

**Cuerpo de la Solicitud:**
```json
{
  "pasos": 5000,
  "distancia_m": 3500,
  "duracion_seg": 6000,
  "calorias_est": 350,
  "completado": true,
  "finalizado_en": "2026-03-30T16:30:00Z"
}
```

| Campo | Tipo | Notas |
|-------|------|-------|
| pasos | number | Total de pasos |
| distancia_m | number | Distancia en metros |
| duracion_seg | number | Duración en segundos |
| calorias_est | number | Calorías estimadas quemadas |
| completado | boolean | Estado de completación de la ruta |
| finalizado_en | string | Datetime ISO cuando se finalizó |

**Respuesta (200 OK):** Objeto ruta actualizado

**Efectos Secundarios:** Cuando `completado: true`, las estadísticas del perfil del usuario (pasos_total, distancia_km) se incrementan mediante RPC.

---

### DELETE /recorridos/:id

Eliminar una ruta (solo del usuario).

**Autenticación:** Requerida - Debe ser dueño de la ruta

**Respuesta (204 Sin Contenido)**

---

## Colecciones

### GET /colecciones

Listar todas las colecciones/categorías activas (público).

**Autenticación:** No requerida

**Parámetros de Query:**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| tipo | string | Filtrar por tipo (ej: "landmark", "dining") |

**Respuesta (200 OK):**
```json
[
  {
    "id": "coleccion-uuid",
    "nombre": "Restaurantes",
    "tipo": "dining",
    "descripcion": "Restaurantes locales y tradicionales",
    "icono": "restaurant",
    "activa": true,
    "pois": { "count": 24 },
    "negocios": { "count": 187 }
  }
]
```

---

### GET /colecciones/:id

Obtener la colección detallada con todos los POIs y negocios.

**Autenticación:** No requerida

**Respuesta (200 OK):**
```json
{
  "id": "coleccion-uuid",
  "nombre": "Restaurantes",
  "tipo": "dining",
  "descripcion": "Restaurantes locales",
  "icono": "restaurant",
  "activa": true,
  "pois": [ /* arreglo de POIs */ ],
  "negocios": [ /* arreglo de negocios */ ]
}
```

**Respuestas de Error:**
- `404` NOT_FOUND: Colección no encontrada o inactiva

---

### POST /colecciones

Crear una nueva colección (solo admin).

**Autenticación:** Requerida - Solo rol Admin

**Cuerpo de la Solicitud:**
```json
{
  "nombre": "Comida Callejera",
  "tipo": "dining",
  "descripcion": "Vendedores de comida callejera locales",
  "icono": "food"
}
```

**Respuesta (201 Creado):** Objeto colección creado

---

### PATCH /colecciones/:id

Actualizar detalles de la colección (solo admin).

**Autenticación:** Requerida - Solo rol Admin

**Cuerpo de la Solicitud:** Campos de la colección a actualizar

**Respuesta (200 OK):** Objeto colección actualizado

---

## Insignias/Logros

### GET /insignias

Obtener catálogo completo de insignias (público).

**Autenticación:** No requerida

**Respuesta (200 OK):**
```json
[
  {
    "id": "insignia-uuid",
    "nombre": "Explorador",
    "descripcion": "Visita 10 ubicaciones diferentes",
    "icono": "badge_explorer",
    "requisito_visitas": 10,
    "coleccion_id": null,
    "colecciones": null
  }
]
```

Ordenado por requisito_visitas ascendente.

---

### GET /insignias/usuario/:userId

Obtener insignias desbloqueadas para un usuario específico (público).

**Autenticación:** No requerida

**Respuesta (200 OK):**
```json
[
  {
    "usuario_id": "user-uuid",
    "insignia_id": "insignia-uuid",
    "obtenida_en": "2026-03-28T10:30:00Z",
    "insignias": {
      "id": "insignia-uuid",
      "nombre": "Explorador",
      "descripcion": "Visita 10 ubicaciones diferentes",
      "icono": "badge_explorer",
      "requisito_visitas": 10
    }
  }
]
```

---

### POST /insignias/check

Verificar y desbloquear insignias para el usuario autenticado según el conteo de visitas.

**Autenticación:** Requerida (token Bearer)

**Cuerpo de la Solicitud:** Vacío

**Respuesta (200 OK):**
```json
{
  "nuevas": [
    {
      "usuario_id": "user-uuid",
      "insignia_id": "insignia-uuid",
      "obtenida_en": "2026-03-31T12:00:00Z",
      "insignias": {
        "id": "insignia-uuid",
        "nombre": "Explorador",
        "icono": "badge_explorer"
      }
    }
  ]
}
```

Devuelve arreglo de insignias recientemente desbloqueadas. Si no hay insignias nuevas disponibles, devuelve `{"nuevas": []}`.

**Lógica:**
1. Contar visitas verificadas para el usuario
2. Obtener insignias ya desbloqueadas
3. Encontrar insignias donde requisito_visitas ≤ conteo de visitas del usuario
4. Bloquear cualquier insignia nueva elegible no desbloqueada anteriormente

---

### POST /insignias

Crear una nueva insignia (solo admin).

**Autenticación:** Requerida - Solo rol Admin

**Cuerpo de la Solicitud:**
```json
{
  "nombre": "Explorador Maestro",
  "descripcion": "Visita 50 ubicaciones diferentes",
  "icono": "badge_master",
  "requisito_visitas": 50,
  "coleccion_id": null
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|----------|-------------|
| nombre | string | Sí | Nombre de la insignia |
| descripcion | string | No | Descripción de la insignia |
| icono | string | Sí | Identificador del icono |
| requisito_visitas | number | Sí | Conteo de visitas requeridas |
| coleccion_id | string | No | Colección opcional |

**Respuesta (201 Creado):** Objeto insignia creado

---

## Reseñas

### GET /resenas

Obtener reseñas (filtradas por negocio si se proporciona query).

**Autenticación:** No requerida

**Parámetros de Query:**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| negocio_id | string | Filtrar por negocio |
| limit | number | Resultados por página (por defecto: 20) |
| offset | number | Desplazamiento de paginación (por defecto: 0) |

**Respuesta (200 OK):**
```json
[
  {
    "id": "resena-uuid",
    "negocio_id": "negocio-uuid",
    "usuario_id": "user-uuid",
    "calificacion": 5,
    "comentario": "¡Servicio excelente y comida deliciosa!",
    "creado_en": "2026-03-30T18:00:00Z",
    "perfiles": {
      "nombre": "Juan Martinez",
      "foto_url": "https://..."
    }
  }
]
```

Ordenado por fecha de creación descendente.

---

### POST /resenas

Crear una nueva reseña (usuario registrado).

**Autenticación:** Requerida (token Bearer)

**Cuerpo de la Solicitud:**
```json
{
  "negocio_id": "negocio-uuid",
  "calificacion": 5,
  "comentario": "¡Un gran lugar para comer!"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|----------|-------------|
| negocio_id | string | Sí | ID del negocio |
| calificacion | number | Sí | Calificación 1-5 |
| comentario | string | No | Texto de la reseña |

**Respuesta (201 Creado):** Objeto reseña creado

**Respuestas de Error:**
- `400` VALIDATION_ERROR: Falta negocio_id o calificación inválida
- `400` INSERT_ERROR: Error de la base de datos

---

### DELETE /resenas/:id

Eliminar una reseña (autor o admin solamente).

**Autenticación:** Requerida (token Bearer)

**Autorización:** Debe ser el autor de la reseña o admin

**Respuesta (204 Sin Contenido)**

**Respuestas de Error:**
- `403` FORBIDDEN: No autorizado para eliminar
- `404` NOT_FOUND: Reseña no encontrada

---

## Visitas

Todos los endpoints requieren autenticación.

### GET /visitas

Obtener el historial de visitas del usuario (más recientes primero).

**Autenticación:** Requerida (token Bearer)

**Respuesta (200 OK):**
```json
[
  {
    "id": "visita-uuid",
    "usuario_id": "user-uuid",
    "lugar_id": "poi-uuid",
    "tipo_lugar": "poi",
    "coleccion_id": "coleccion-uuid",
    "latitud": 19.4326,
    "longitud": -99.1332,
    "visitado_en": "2026-03-30T14:30:00Z"
  }
]
```

---

### POST /visitas

Registrar una visita de ubicación con validación GPS opcional.

**Autenticación:** Requerida (token Bearer)

**Cuerpo de la Solicitud:**
```json
{
  "lugar_id": "uuid-poi-o-negocio",
  "tipo_lugar": "poi",
  "coleccion_id": "coleccion-uuid",
  "latitud": 19.4326,
  "longitud": -99.1332
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|----------|-------------|
| lugar_id | string | Sí | ID del POI o negocio |
| tipo_lugar | string | Sí | `"poi"` o `"negocio"` |
| coleccion_id | string | No | Categoría/colección |
| latitud | number | No | Latitud GPS para verificación |
| longitud | number | No | Longitud GPS para verificación |

**Respuesta (201 Creado):**
```json
{
  "id": "visita-uuid",
  "usuario_id": "user-uuid",
  "lugar_id": "poi-uuid",
  "tipo_lugar": "poi",
  "coleccion_id": "coleccion-uuid",
  "latitud": 19.4326,
  "longitud": -99.1332,
  "visitado_en": "2026-03-31T12:15:00Z",
  "verificada": true
}
```

**Verificación GPS:**
- Si `latitud` y `longitud` se proporcionan, la visita se verifica si está dentro de 100 metros de la ubicación
- El campo `verificada` indica el estado de la verificación GPS
- Para negocios: Si la visita es verificada por GPS, incrementa el contador diario `visitas_gps` en negocio_stats

**Respuestas de Error:**
- `400` VALIDATION_ERROR: Faltan campos requeridos o tipo_lugar inválido

---

## Formato de Respuesta de Error

Todas las respuestas de error siguen este formato:

```json
{
  "error": {
    "message": "Descripción de lo que salió mal",
    "code": "ERROR_CODE",
    "statusCode": 400
  }
}
```

### Códigos de Error Comunes

| Código | Estado | Descripción |
|--------|--------|-------------|
| VALIDATION_ERROR | 400 | Datos de entrada inválidos |
| AUTH_ERROR | 400/401 | Fallo de autenticación |
| UNAUTHORIZED | 401 | Token faltante o inválido |
| FORBIDDEN | 403 | Permisos insuficientes |
| NOT_FOUND | 404 | Recurso no encontrado |
| UPDATE_ERROR | 400 | Fallo en la actualización de la base de datos |
| INSERT_ERROR | 400 | Fallo en la inserción de la base de datos |
| DELETE_ERROR | 400 | Fallo en la eliminación de la base de datos |
| DB_ERROR | 500 | Error de consulta a la base de datos |
| PROFILE_CREATE_ERROR | 500 | Fallo en la creación del perfil |

---

## Detalles de Autenticación

### Formato de Token Bearer

Incluir el token JWT en el encabezado de Autorización:
```
Authorization: Bearer eyJhbGc...
```

### Roles de Usuario

- **turista**: Usuario regular, puede ver contenido y crear datos personales (visitas, rutas, reseñas)
- **empresa**: Propietario de negocio, puede gestionar su negocio y productos
- **admin**: Administrador, puede gestionar todo el contenido incluyendo POIs, colecciones, insignias y amenidades

### Expiración de Token

- `access_token`: Expira en 3600 segundos (1 hora)
- `refresh_token`: Larga vida, usar para obtener nuevos tokens de acceso

---

## Paginación

Los endpoints de listado soportan paginación:

**Parámetros de Query:**
- `limit`: Número de resultados por página (por defecto varía según endpoint)
- `offset`: Posición de inicio (basado en 0)

**Ejemplo:**
```
GET /pois?limit=20&offset=40
```

Devuelve resultados 40-59 (20 items comenzando en posición 40).

---

## Marcas de Tiempo

Todas las marcas de tiempo están en formato ISO 8601 (UTC):
```
2026-03-31T12:00:00Z
```

---

## Limitación de Velocidad

Actualmente no hay implementación de limitación de velocidad. Las versiones futuras pueden incluir encabezados de límite de velocidad:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1617206400
```

---

## Versionamiento

Versión actual de la API: **v1**

Todos los endpoints usan el prefijo `/api/v1/`.

Las versiones futuras (si es necesario) usarían `/api/v2/`, `/api/v3/`, etc.

---

## Configuración de CORS

**Orígenes Permitidos (Desarrollo):**
- `http://localhost:3000`
- `http://localhost:5000`

Para despliegue en producción, actualizar la configuración de CORS en `backend/src/main.ts`.

---

## Soporte

Para problemas o preguntas sobre los endpoints de la API:
1. Revisar esta documentación primero
2. Revisar los mensajes de error y códigos de error
3. Verificar que el token de autenticación es válido
4. Asegurar que se tienen los permisos requeridos para el endpoint

---

**Fin de la Documentación de la API v1.0**

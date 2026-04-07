# Muul Backend (Preparacion)

Esta carpeta deja preparado el backend para iniciar desarrollo en paralelo con apps Android, iOS y Web.

## Objetivo inicial

- Exponer API para autenticacion y sesion.
- Exponer API para catalogo de lugares y negocios.
- Exponer API para rutas y logros.
- Centralizar persistencia de datos para todas las plataformas.

## Estructura propuesta

```text
backend/
  src/
    api/
    application/
    domain/
    infrastructure/
  tests/
  .env.example
  package.json
  tsconfig.json
  Dockerfile
```

## Comandos iniciales

```bash
cd backend
npm install
npm run dev
```

## Nota

Este backend esta en modo bootstrap. Incluye configuracion base para arrancar rapido y evolucionar por modulos.

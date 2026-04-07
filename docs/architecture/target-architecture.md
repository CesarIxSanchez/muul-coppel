# Target Architecture (Draft)

## Objetivo

Trabajar en paralelo sobre 4 frentes:

- App Android
- App iOS
- App Web
- Backend

## Principios

- Separacion de responsabilidades por modulo.
- Contratos API versionados y documentados.
- Reutilizacion de logica comun en packages.
- Escalabilidad para nuevas funciones y regiones.

## Mapa de carpetas

```text
apps/
  android_app/
  ios_app/
  web_app/
backend/
packages/
  core/
  ui/
  services/
  data/
```

## Integracion esperada

1. Las apps consumen API del backend.
2. `packages/core` guarda reglas y modelos base.
3. `packages/services` centraliza casos de uso cliente.
4. `packages/data` concentra acceso a fuentes locales/remotas.
5. `packages/ui` concentra componentes visuales reutilizables.

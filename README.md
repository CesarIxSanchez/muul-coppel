# Muul Workspace

Base de trabajo para el proyecto Muul, preparada para desarrollo paralelo de backend y clientes por plataforma.

## Estructura actual

```text
muul/
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
	docs/
		architecture/
		requirements/
	assets/
		images/
		icons/
	.github/
```

## Que se preparó

- Limpieza de documentos de apoyo del equipo y PDFs de trabajo interno.
- Reorganizacion por plataforma para Android, iOS y Web.
- Carpeta backend creada con configuracion base de arranque.
- Espacio de documentacion para arquitectura y requerimientos.

## Arranque rapido

Android app:

1. `cd apps/android_app`
2. `flutter pub get`
3. `flutter run -d android`

iOS app:

1. `cd apps/ios_app`
2. `flutter pub get`
3. `flutter run -d ios`

Web app:

1. `cd apps/web_app`
2. `flutter pub get`
3. `flutter run -d chrome`

Backend:

1. `cd backend`
2. `npm install`
3. `npm run dev`

## Proximo paso recomendado

Definir contratos API (auth, places, business, routes, achievements) en `docs/requirements/` antes de implementar modulos.

# Muul Workspace

Base de trabajo para el proyecto Muul, preparada para desarrollo paralelo de backend y clientes por plataforma.

## Estructura actual

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
docs/
	architecture/
	requirements/
assets/
	images/
	icons/
```

## Arranque rapido

Android app:

1. `cd apps/android_app`
2. `flutter pub get`
3. `flutter run -d android`

iOS app:

1. `cd apps/ios_app`
2. `flutter pub get`
3. `flutter run -d ios`


Backend:

1. `cd backend`
2. `npm install`
3. `npm run dev`

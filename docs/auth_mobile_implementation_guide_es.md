# Muul - Guía de Implementación y Pruebas (Auth/Sesión/Perfil)

## 1. Configuración que debes hacer tú (una sola vez)

1. En Supabase, ejecuta el script SQL:
   - backend/supabase/migrations/20260331_auth_profiles_rls.sql
2. En Supabase Auth, confirma:
   - Email provider activo
   - Confirmación de email desactivada para pruebas locales (opcional)
3. Levanta backend local:
   - cd muul/backend
   - npm run dev
4. Ejecuta app Android:
   - cd muul/apps/android_app
   - flutter pub get
   - flutter run --dart-define=SUPABASE_URL=TU_URL --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY
5. Ejecuta app iOS:
   - cd muul/apps/ios_app
   - flutter pub get
   - flutter run --dart-define=SUPABASE_URL=TU_URL --dart-define=SUPABASE_ANON_KEY=TU_ANON_KEY

## 2. Variables opcionales de API

- LOCAL_API_BASE_URL: por defecto usa:
  - Android emulator: http://10.0.2.2:8080/api/v1
  - iOS simulator: http://localhost:8080/api/v1
- USE_PROD_API=true para usar Vercel
- PROD_API_BASE_URL=https://muul-api.vercel.app/api/v1

Ejemplo:

flutter run \
  --dart-define=SUPABASE_URL=TU_URL \
  --dart-define=SUPABASE_ANON_KEY=TU_KEY \
  --dart-define=LOCAL_API_BASE_URL=http://localhost:8080/api/v1

## 3. Flujo de prueba funcional (manual)

1. Abrir app por primera vez -> Login
2. Tap en "Regístrate ahora"
3. Paso 1:
   - correo válido
   - contraseña con mínimo 8, mayúscula, número y símbolo
4. Paso 2:
   - username + género
   - guardar
5. Verifica que llegue a Home (mock)
6. Ir a Perfil (bottom nav)
7. Editar perfil:
   - cambiar username una vez
   - intentar cambiar nuevamente dentro de 30 días (debe bloquear)
8. Cerrar sesión
9. Iniciar sesión otra vez
10. Cerrar app completamente y reabrir
    - si la sesión es válida debe entrar directo sin login

## 4. Flujo de negocio

1. Desde Home, "Registrar negocio"
2. Capturar nombre y dirección
3. Ver aviso de inmutabilidad
4. Guardar
5. Abrir Perfil de Negocio
6. Intentar editar nombre/dirección:
   - UI debe mostrarlos bloqueados
   - DB también lo bloquea por trigger

## 5. Mini guía para simulador Android/iOS

### Android (emulador)

1. Abrir Android Studio > Device Manager > crear/arrancar AVD
2. En terminal:
   - cd muul/apps/android_app
   - flutter pub get
   - flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
3. Si backend está en tu máquina local, usa 10.0.2.2 en LOCAL_API_BASE_URL

### iOS (simulador)

1. Xcode instalado y command line tools activas
2. Abrir Simulator
3. En terminal:
   - cd muul/apps/ios_app
   - flutter pub get
   - flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
4. En iOS simulator localhost funciona para backend local

## 6. Notas de seguridad implementadas

- Supabase GoTrue para hashing y manejo de credenciales
- Validación de complejidad de contraseña en cliente
- RLS estricta por auth.uid() para users/businesses
- Username único y autocorrección con sufijo aleatorio
- Cambio de username limitado a 1 vez cada 30 días
- Nombre y dirección de negocio inmutables por trigger
- Refresh token guardado en almacenamiento seguro del dispositivo

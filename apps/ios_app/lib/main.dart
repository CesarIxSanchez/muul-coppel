import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/config/app_config.dart';
import 'src/muul_app.dart';
import 'src/state/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppConfig.hasSupabaseConfig) {
    runApp(const _MissingConfigApp());
    return;
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );

  final sessionController = SessionController();
  await sessionController.bootstrap();

  runApp(MuulApp(sessionController: sessionController));
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Falta configurar SUPABASE_URL y SUPABASE_ANON_KEY via --dart-define.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

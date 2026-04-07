// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_colors.dart';
import 'main_shell.dart';
import 'features/explore/presentation/screens/search_screen.dart';
import 'features/places/presentation/screens/place_detail_screen.dart';
import 'features/places/presentation/screens/business_detail_screen.dart';
import 'features/business/presentation/screens/my_business_profile_screen.dart';
import 'features/map/presentation/map_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/state/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. Cargar variables de entorno desde .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('.env file not found, using defaults: $e');
  }

  // 1. Inicializar Mapbox
  MapboxOptions.setAccessToken(AppConstants.mapboxToken);

  // 2. Inicializar Supabase
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  runApp(
    const ProviderScope(
      child: MuulApp(),
    ),
  );
}

class MuulApp extends StatelessWidget {
  const MuulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgApp,
        colorScheme: const ColorScheme.dark(
          primary:   AppColors.primary,
          secondary: AppColors.secondary,
          error:     AppColors.accent,
          surface:   AppColors.bgCard,
        ),
      ),
      // MainShell es la pantalla raíz con bottom nav persistente, protegiéndola con un AuthGate
      home: AuthGate(),
      routes: {
        '/map': (context) => const MapScreen(),
        '/search': (context) => const SearchScreen(),
        '/place_detail': (context) => const PlaceDetailScreen(),
        '/business_detail': (context) => const BusinessDetailScreen(),
        '/business_profile': (context) => const MyBusinessProfileScreen(),
      },

    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final SessionController _sessionController = SessionController();

  @override
  void initState() {
    super.initState();
    _sessionController.bootstrap();
  }

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sessionController,
      builder: (context, _) {
        if (!_sessionController.ready) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (_sessionController.isAuthenticated) {
          return const MainShell();
        }

        return LoginScreen(
          sessionController: _sessionController,
          onLoginSuccess: () {},
        );
      },
    );
  }
}
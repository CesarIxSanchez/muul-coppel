import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'state/session_controller.dart';
import 'theme/muul_theme.dart';

class MuulApp extends StatelessWidget {
  const MuulApp({super.key, required this.sessionController});

  final SessionController sessionController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sessionController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Muul',
          theme: MuulTheme.dark(),
          home: _resolveInitialScreen(),
        );
      },
    );
  }

  Widget _resolveInitialScreen() {
    if (!sessionController.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (sessionController.isAuthenticated) {
      return HomeScreen(sessionController: sessionController);
    }

    return LoginScreen(
      sessionController: sessionController,
      onLoginSuccess: () {},
    );
  }
}

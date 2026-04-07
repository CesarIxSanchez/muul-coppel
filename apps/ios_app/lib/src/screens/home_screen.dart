import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/muul_api_client.dart';
import '../state/session_controller.dart';
import 'register_business_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.sessionController});

  final SessionController sessionController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  late final MuulApiClient _api;
  String _status = 'Sin verificar';

  @override
  void initState() {
    super.initState();
    _api = MuulApiClient(AppConfig.apiBaseUrl);
  }

  Future<void> _checkBackend() async {
    try {
      final ok = await _api.checkHealth();
      if (!mounted) return;
      setState(() => _status = ok ? 'Backend local activo' : 'Backend no disponible');
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = 'Error al conectar backend');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeMock(
        status: _status,
        onCheckBackend: _checkBackend,
        onOpenBusinessRegister: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RegisterBusinessScreen(sessionController: widget.sessionController),
            ),
          );
        },
      ),
      UserProfileScreen(sessionController: widget.sessionController),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeMock extends StatelessWidget {
  const _HomeMock({
    required this.status,
    required this.onCheckBackend,
    required this.onOpenBusinessRegister,
  });

  final String status;
  final VoidCallback onCheckBackend;
  final VoidCallback onOpenBusinessRegister;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Home (Mockup)',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Estado backend: $status'),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onCheckBackend,
              child: const Text('Verificar backend local'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onOpenBusinessRegister,
              child: const Text('Registrar negocio'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Usa la pestaña Perfil en el menú inferior para validar edición de usuario, idioma y cierre de sesión.',
            ),
          ],
        ),
      ),
    );
  }
}

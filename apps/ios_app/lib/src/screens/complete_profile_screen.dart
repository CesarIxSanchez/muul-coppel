import 'package:flutter/material.dart';

import '../models/profile_models.dart';
import '../services/profile_service.dart';
import '../state/session_controller.dart';
import 'home_screen.dart';
import 'register_business_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({
    super.key,
    required this.sessionController,
    this.suggestBusinessFlow = false,
  });

  final SessionController sessionController;
  final bool suggestBusinessFlow;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _service = ProfileService();
  final _usernameCtrl = TextEditingController();
  UserGender _gender = UserGender.notSpecified;
  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_usernameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un username.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.createUserProfile(
        username: _usernameCtrl.text,
        gender: _gender,
      );
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(sessionController: widget.sessionController),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando perfil: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Paso 2 de 2'),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username (sin @)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserGender>(
              initialValue: _gender,
              items: UserGender.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                  .toList(),
              onChanged: (value) => setState(() => _gender = value ?? UserGender.notSpecified),
              decoration: const InputDecoration(labelText: 'Género'),
            ),
            if (widget.suggestBusinessFlow) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RegisterBusinessScreen(
                        sessionController: widget.sessionController,
                      ),
                    ),
                  );
                },
                child: const Text('¿Te registras como negocio? Crear perfil de negocio ahora'),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: _loading ? null : _saveProfile,
              child: const Text('Guardar perfil y continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

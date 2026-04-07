import 'package:flutter/material.dart';

import '../models/profile_models.dart';
import '../services/profile_service.dart';
import '../state/session_controller.dart';

class CompleteBusinessProfileScreen extends StatefulWidget {
  const CompleteBusinessProfileScreen({
    super.key,
    required this.sessionController,
  });

  final SessionController sessionController;

  @override
  State<CompleteBusinessProfileScreen> createState() => _CompleteBusinessProfileScreenState();
}

class _CompleteBusinessProfileScreenState extends State<CompleteBusinessProfileScreen> {
  final _service = ProfileService();
  final _businessNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _language = 'es-MX';
  bool _loading = false;

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBusinessProfile() async {
    if (_businessNameCtrl.text.trim().isEmpty || _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre y direccion del negocio.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.registerBusiness(
        businessName: _businessNameCtrl.text,
        address: _addressCtrl.text,
        language: _language,
      );

      await _service.createUserProfile(
        username: _businessNameCtrl.text,
        gender: UserGender.notSpecified,
        language: _language,
      );

      if (!mounted) return;
      // Volver al AuthGate (raíz) – detectará la sesión activa y mostrará MainShell
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando negocio: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar negocio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Paso 2 de 2'),
            const SizedBox(height: 16),
            TextField(
              controller: _businessNameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del negocio'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Direccion del negocio'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _language,
              items: const [
                DropdownMenuItem(value: 'es-MX', child: Text('Espanol (Mexico)')),
                DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
                DropdownMenuItem(value: 'pt-BR', child: Text('Portugues (Brasil)')),
                DropdownMenuItem(value: 'zh-CN', child: Text('Chino Mandarin')),
              ],
              onChanged: (value) => setState(() => _language = value ?? 'es-MX'),
              decoration: const InputDecoration(labelText: 'Idioma favorito'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _loading ? null : _saveBusinessProfile,
              child: const Text('Guardar y continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

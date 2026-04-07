import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../state/session_controller.dart';
import 'business_profile_screen.dart';

class RegisterBusinessScreen extends StatefulWidget {
  const RegisterBusinessScreen({super.key, required this.sessionController});

  final SessionController sessionController;

  @override
  State<RegisterBusinessScreen> createState() => _RegisterBusinessScreenState();
}

class _RegisterBusinessScreenState extends State<RegisterBusinessScreen> {
  final _service = ProfileService();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _language = 'es-MX';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty || _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre y dirección del negocio.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.registerBusiness(
        businessName: _nameCtrl.text,
        address: _addressCtrl.text,
        language: _language,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BusinessProfileScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de negocio')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x22FFB74D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Aviso de seguridad: El Nombre y la Dirección del negocio no podrán ser cambiados después de la creación.',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del negocio'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _language,
              items: const [
                DropdownMenuItem(value: 'es-MX', child: Text('Español (México)')),
                DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
              ],
              onChanged: (v) => setState(() => _language = v ?? 'es-MX'),
              decoration: const InputDecoration(labelText: 'Idioma'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _loading ? null : _register,
              child: const Text('Crear perfil de negocio'),
            ),
          ],
        ),
      ),
    );
  }
}

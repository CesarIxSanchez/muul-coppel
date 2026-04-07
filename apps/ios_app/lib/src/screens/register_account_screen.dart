import 'package:flutter/material.dart';

import '../state/session_controller.dart';
import 'complete_profile_screen.dart';

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({
    super.key,
    required this.sessionController,
    this.defaultBusinessMode = false,
  });

  final SessionController sessionController;
  final bool defaultBusinessMode;

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isStrongPassword(String value) {
    final hasLength = value.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasNumber = RegExp(r'\d').hasMatch(value);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(value);
    return hasLength && hasUpper && hasNumber && hasSymbol;
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await widget.sessionController.signUp(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CompleteProfileScreen(
            sessionController: widget.sessionController,
            suggestBusinessFlow: widget.defaultBusinessMode,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro individual')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Paso 1 de 2'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
                  if (!valid) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (value) {
                  final v = value ?? '';
                  if (!_isStrongPassword(v)) {
                    return 'Mínimo 8 chars, mayúscula, número y símbolo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                validator: (value) {
                  if (value != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('La contraseña debe incluir mayúsculas, número y símbolo.'),
              const Spacer(),
              FilledButton(
                onPressed: widget.sessionController.loading ? null : _continue,
                child: const Text('Continuar a completar perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

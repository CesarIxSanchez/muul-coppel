import 'package:flutter/material.dart';

import '../state/session_controller.dart';
import '../widgets/muul_background.dart';
import '../../core/constants/app_colors.dart';
import 'complete_business_profile_screen.dart';
import 'complete_profile_screen.dart';

enum RegistrationType { tourist, business }

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({
    super.key,
    required this.sessionController,
    required this.registrationType,
  });

  final SessionController sessionController;
  final RegistrationType registrationType;

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordCtrl.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordCtrl.text);
  bool get _hasNumber => RegExp(r'\d').hasMatch(_passwordCtrl.text);
  bool get _hasSymbol => RegExp(r'[^A-Za-z0-9]').hasMatch(_passwordCtrl.text);
  bool get _passwordsMatch =>
      _confirmCtrl.text.isNotEmpty && _passwordCtrl.text == _confirmCtrl.text;

  bool get _passwordIsStrong => _hasMinLength && _hasUppercase && _hasNumber && _hasSymbol;

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_passwordIsStrong || !_passwordsMatch) return;

    try {
      await widget.sessionController.signUp(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;

      if (widget.registrationType == RegistrationType.tourist) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CompleteProfileScreen(sessionController: widget.sessionController),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CompleteBusinessProfileScreen(
              sessionController: widget.sessionController,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar: $e')),
      );
    }
  }

  Widget _ruleLine({required bool ok, required String okText, required String failText}) {
    final bgColor = ok ? const Color(0x1829D67F) : const Color(0x18F97066);
    final textColor = ok ? const Color(0xFF84F2B8) : const Color(0xFFF3A6A0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ok ? const Color(0x334AD892) : const Color(0x33F97066)),
      ),
      child: Row(
        children: [
          Text(ok ? '✅' : '❌', style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok ? okText : failText,
              style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusiness = widget.registrationType == RegistrationType.business;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isBusiness ? 'Registro negocio' : 'Registro turista'),
      ),
      body: MuulBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 390),
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Paso 1 de 2',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 20),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
                  if (!valid) return 'Correo invalido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) return 'Ingresa una contraseña';
                  if (!_passwordIsStrong) return 'Tu contraseña no cumple los requisitos';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) return 'Confirma tu contraseña';
                  if (value != _passwordCtrl.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Seguridad de contraseña',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFA1A8B8),
                      letterSpacing: 0.6,
                    ),
              ),
              _ruleLine(
                ok: _hasMinLength,
                okText: 'Minimo de 8 caracteres',
                failText: 'Minimo de 8 caracteres',
              ),
              _ruleLine(
                ok: _hasUppercase,
                okText: 'Incluye mayúscula',
                failText: 'Falta una mayúscula ',
              ),
              _ruleLine(
                ok: _hasNumber,
                okText: 'Incluye número',
                failText: 'Falta un número',
              ),
              _ruleLine(
                ok: _hasSymbol,
                okText: 'Incluye símbolo',
                failText: 'Símbolo faltante',
              ),
              _ruleLine(
                ok: _passwordsMatch,
                okText: 'Contraseñas coinciden',
                failText: 'Las contraseñas no coinciden',
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: widget.sessionController.loading ? null : _continue,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    ),
    ),
    ),
    ),
    );
  }
}



import 'package:flutter/material.dart';

import '../state/session_controller.dart';
import '../theme/muul_theme.dart';
import '../widgets/muul_background.dart';
import 'register_account_screen.dart';
import '../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.sessionController,
    required this.onLoginSuccess,
  });

  final SessionController sessionController;
  final VoidCallback onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await widget.sessionController.signIn(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      widget.onLoginSuccess();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(_friendlyError(e));
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid_credentials') || msg.contains('invalid login')) {
      return 'Correo o contraseña incorrectos. Verifica tus datos.';
    }
    if (msg.contains('email_not_confirmed')) {
      return 'Tu correo aún no ha sido confirmado. Revisa tu bandeja.';
    }
    if (msg.contains('too_many_requests') || msg.contains('rate_limit')) {
      return 'Demasiados intentos. Espera un momento antes de intentar de nuevo.';
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
      return 'Sin conexión a internet. Verifica tu red e intenta de nuevo.';
    }
    if (msg.contains('user_not_found')) {
      return 'No existe una cuenta con este correo.';
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
          ],
        ),
        backgroundColor: AppColors.accent.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _openRegistrationTypeSelector() async {
    final type = await showModalBottomSheet<RegistrationType>(
      context: context,
      backgroundColor: const Color(0xFF171D2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selecciona tipo de cuenta',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: const Color(0xFF1F2638),
                  leading: const Icon(Icons.person),
                  title: const Text('Turista'),
                  onTap: () => Navigator.pop(context, RegistrationType.tourist),
                ),
                const SizedBox(height: 10),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: const Color(0xFF1F2638),
                  leading: const Icon(Icons.storefront),
                  title: const Text('Negocio'),
                  onTap: () => Navigator.pop(context, RegistrationType.business),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (type == null || !mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterAccountScreen(
          sessionController: widget.sessionController,
          registrationType: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MuulBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 12),
                      Container(
                        width: 86,
                        height: 86,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.explore, size: 40, color: Colors.white),
                      ),
                      Text(
                        'MUUL',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 6,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Bienvenido a la Copa',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu conserje digital para el Mundial 2026.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: MuulTheme.textMuted,
                            ),
                      ),
                      const SizedBox(height: 20),
                      const _FieldLabel('CORREO ELECTRONICO'),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          final valid = email.contains('@') &&
                              !email.startsWith('@') &&
                              !email.endsWith('@') &&
                              !email.contains(' ');
                          if (!valid) return 'Correo invalido';
                          return null;
                        },
                        decoration: const InputDecoration(hintText: 'nombre@ejemplo.com'),
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel('CONTRASENA'),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        validator: (value) {
                          if ((value ?? '').isEmpty) return 'Ingresa tu contrasena';
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _remember,
                            onChanged: (v) => setState(() => _remember = v ?? false),
                          ),
                          const Text('Recordarme'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: const Size(0, 36),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Olvidaste tu contrasena?',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: widget.sessionController.loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Iniciar Sesion'),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'O CONTINUA CON',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: MuulTheme.textMuted,
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: 14),
                      const _FakeSocialButton(text: 'Google'),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No tienes una cuenta? '),
                          TextButton(
                            onPressed: _openRegistrationTypeSelector,
                            child: const Text('Registrate ahora'),
                          ),
                        ],
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: MuulTheme.textMuted,
              letterSpacing: 2,
            ),
      ),
    );
  }
}

class _FakeSocialButton extends StatelessWidget {
  const _FakeSocialButton({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.link),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

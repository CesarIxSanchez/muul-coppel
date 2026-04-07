import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../src/services/auth_session_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _displayName = '';
  String _email = '';
  bool _isBusiness = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    String name = 'Usuario';
    String email = user?.email ?? '';

    // Intentar obtener el username de la tabla users
    if (user != null) {
      try {
        final data = await client.from('users').select('username').eq('id', user.id).maybeSingle();
        if (data != null && data['username'] != null) {
          name = data['username'] as String;
        } else {
          name = email.split('@').first;
        }
      } catch (_) {
        name = email.split('@').first;
      }
    }

    // Verificar si tiene perfil de negocio
    if (user != null) {
      try {
        final biz = await client.from('businesses').select('id').eq('id', user.id).maybeSingle();
        if (biz != null) {
          name = name; // keep whatever name we got
          _isBusiness = true;
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _displayName = name;
        _email = email;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mi Perfil',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Avatar con inicial del nombre
              Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: _loading
                    ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        _displayName.replaceAll('@', '').isNotEmpty
                            ? _displayName.replaceAll('@', '')[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: AppColors.secondary, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const SizedBox(height: 26, width: 26, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      _displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
              const SizedBox(height: 4),
              Text(_email, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 32),

              // Estadísticas Rápidas
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(label: 'Lugares', value: '12', icon: Icons.location_on),
                  _StatItem(label: 'Rutas', value: '4', icon: Icons.route),
                  _StatItem(label: 'Siguiendo', value: '28', icon: Icons.people),
                ],
              ),
              const SizedBox(height: 40),

              // Solo mostrar gestión de negocio si el usuario es tipo negocio
              if (_isBusiness)
                _ProfileOption(
                  icon: Icons.storefront_outlined,
                  label: 'Gestión de mi Negocio',
                  onTap: () {
                    Navigator.pushNamed(context, '/business_profile');
                  },
                ),
              _ProfileOption(icon: Icons.bookmark_outline, label: 'Lugares guardados', onTap: () {}),
              _ProfileOption(icon: Icons.history, label: 'Historial de visitas', onTap: () {}),
              _ProfileOption(icon: Icons.notifications_none_outlined, label: 'Notificaciones', onTap: () {}),
              _ProfileOption(icon: Icons.settings_outlined, label: 'Configuración', onTap: () {}),

              const SizedBox(height: 40),

              // Botón de Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.bgCard,
                        title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                        content: const Text(
                          '¿Estás seguro de que quieres cerrar sesión?',
                          style: TextStyle(color: Colors.grey),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      // Usar AuthSessionService para limpiar también el token persistido
                      final authService = AuthSessionService();
                      await authService.signOut();
                    }
                  },
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text('Muul v1.0.0 • Mundial 2026', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.secondary.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondary, size: 22),
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[800], size: 20),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/profile_models.dart';
import '../services/profile_service.dart';
import '../state/session_controller.dart';
import '../theme/muul_theme.dart';
import '../widgets/muul_background.dart';
import 'business_profile_screen.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.sessionController});

  final SessionController sessionController;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _service = ProfileService();
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _profile = await _service.getMyUserProfile();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editProfile() async {
    if (_profile == null) return;

    final usernameCtrl = TextEditingController(text: _profile!.username.replaceAll('@', ''));
    var selectedGender = _profile!.gender;
    var selectedLanguage = _profile!.language;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar perfil'),
        content: StatefulBuilder(
          builder: (context, setLocal) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserGender>(
                  initialValue: selectedGender,
                  items: UserGender.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                      .toList(),
                  onChanged: (v) => setLocal(() => selectedGender = v ?? UserGender.notSpecified),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedLanguage,
                  items: const [
                    DropdownMenuItem(value: 'es-MX', child: Text('Español (México)')),
                    DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
                  ],
                  onChanged: (v) => setLocal(() => selectedLanguage = v ?? 'es-MX'),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (saved != true) return;

    try {
      await _service.updateUserProfile(
        newUsername: usernameCtrl.text,
        gender: selectedGender,
        language: selectedLanguage,
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _logout() async {
    await widget.sessionController.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          sessionController: widget.sessionController,
          onLoginSuccess: () {},
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final p = _profile;

    return Scaffold(
      body: MuulBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xCC0D121D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF53607C)),
              ),
              child: p == null
                  ? const Center(child: Text('No hay perfil de usuario, completa tu registro.'))
                  : ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu),
                            const SizedBox(width: 10),
                            const Text('MUUL', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(p.avatarUrl ?? 'https://i.pravatar.cc/300?img=12'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: CircleAvatar(
                            radius: 58,
                            backgroundImage: NetworkImage(p.avatarUrl ?? 'https://i.pravatar.cc/300?img=12'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF93D8A7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('TURISTA', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.username,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          p.gender.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: MuulTheme.textMuted),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            Expanded(child: _StatCard(title: 'RUTAS', value: '24', icon: Icons.route)),
                            SizedBox(width: 8),
                            Expanded(child: _StatCard(title: 'ESTADIOS', value: '08', icon: Icons.stadium)),
                            SizedBox(width: 8),
                            Expanded(child: _StatCard(title: 'NIVEL', value: 'Lvl 12', icon: Icons.workspace_premium)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('CONFIGURACIÓN', style: TextStyle(letterSpacing: 2, color: MuulTheme.textMuted)),
                        const SizedBox(height: 10),
                        _ConfigTile(
                          icon: Icons.translate,
                          title: 'Idioma',
                          subtitle: p.language,
                          onTap: _editProfile,
                        ),
                        _ConfigTile(
                          icon: Icons.palette,
                          title: 'Tema de la App',
                          subtitle: 'Default',
                          onTap: () {},
                        ),
                        _ConfigTile(
                          icon: Icons.edit,
                          title: 'Editar Perfil',
                          onTap: _editProfile,
                        ),
                        _ConfigTile(
                          icon: Icons.store,
                          title: 'Perfil de Negocio',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const BusinessProfileScreen()),
                            );
                          },
                        ),
                        _ConfigTile(
                          icon: Icons.logout,
                          title: 'Cerrar Sesión',
                          titleColor: const Color(0xFFF1A7A7),
                          onTap: _logout,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF171D2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFAFC8FF)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          Text(title, style: const TextStyle(color: MuulTheme.textMuted)),
        ],
      ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  const _ConfigTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF171D2A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(color: MuulTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

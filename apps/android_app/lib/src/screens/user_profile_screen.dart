import 'package:flutter/material.dart';

import '../models/profile_models.dart';
import '../services/profile_service.dart';
import '../state/session_controller.dart';
import '../theme/muul_theme.dart';
import '../widgets/muul_background.dart';
import 'edit_profile_screen.dart';
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
  BusinessProfile? _businessProfile;
  bool _loading = true;

  bool get _isBusiness => _businessProfile != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _profile = await _service.getMyUserProfile();
      _businessProfile = await _service.getMyBusinessProfile();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editProfile() async {
    final profile = _profile;
    if (profile == null) return;

    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          profile: profile,
          isBusiness: _isBusiness,
          businessProfile: _businessProfile,
        ),
      ),
    );

    if (saved == true && mounted) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado.')),
      );
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

  String _preferredUsernameFromDb(String dbUsername) {
    final base = dbUsername.replaceFirst('@', '');
    final match = RegExp(r'^(.*?)(\d{5})$').firstMatch(base);
    if (match == null) return base;
    return match.group(1) ?? base;
  }

  String _businessFallbackAvatar() {
    return 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=400&q=80';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final p = _profile;

    if (p == null) {
      return const Scaffold(
        body: Center(child: Text('No hay perfil de usuario, completa tu registro.')),
      );
    }

    final business = _businessProfile;
    final badgeText = _isBusiness ? 'NEGOCIO' : 'TURISTA';
    final badgeColor = _isBusiness ? const Color(0xFFFFB74D) : const Color(0xFF93D8A7);
    final preferredUsername = _preferredUsernameFromDb(p.username);
    final dbUsernameLine = '@$preferredUsername' == p.username ? null : p.username;
    final displayName = _isBusiness ? (business?.businessName ?? preferredUsername) : preferredUsername;
    final businessAvatar = business?.avatarUrl;
    final avatarUrl = _isBusiness
      ? ((businessAvatar == null || businessAvatar.isEmpty || businessAvatar.contains('pravatar'))
        ? _businessFallbackAvatar()
        : businessAvatar)
      : (p.avatarUrl ?? 'https://i.pravatar.cc/300?img=12');
    final languageLabel = _isBusiness ? (business?.language ?? p.language) : p.language;

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
              child: ListView(
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
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: CircleAvatar(
                      radius: 58,
                      backgroundImage: NetworkImage(avatarUrl),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (dbUsernameLine != null)
                    Text(
                      dbUsernameLine,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: MuulTheme.textMuted, fontSize: 20),
                    ),
                  if (!_isBusiness)
                    Text(
                      p.gender.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: MuulTheme.textMuted),
                    ),
                  const SizedBox(height: 14),
                  if (!_isBusiness)
                    const Row(
                      children: [
                        Expanded(child: _StatCard(title: 'RUTAS', value: '24', icon: Icons.route)),
                        SizedBox(width: 8),
                        Expanded(child: _StatCard(title: 'ESTADIOS', value: '08', icon: Icons.stadium)),
                        SizedBox(width: 8),
                        Expanded(child: _StatCard(title: 'NIVEL', value: 'Lvl 12', icon: Icons.workspace_premium)),
                      ],
                    ),
                  if (!_isBusiness) const SizedBox(height: 16),
                  const Text('CONFIGURACION', style: TextStyle(letterSpacing: 2, color: MuulTheme.textMuted)),
                  const SizedBox(height: 10),
                  _ConfigTile(
                    icon: Icons.translate,
                    title: 'Idioma',
                    subtitle: languageLabel,
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
                  if (_isBusiness)
                    const _ConfigTile(
                      icon: Icons.store,
                      title: 'Perfil de Negocio (Mockup)',
                      subtitle: 'Proximamente',
                      onTap: null,
                    ),
                  _ConfigTile(
                    icon: Icons.logout,
                    title: 'Cerrar Sesion',
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
  final VoidCallback? onTap;

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
        enabled: onTap != null,
        leading: Icon(icon),
        title: Text(title, style: TextStyle(color: titleColor)),
        subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(color: MuulTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

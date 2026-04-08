import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../src/services/auth_session_service.dart';

class MyBusinessProfileScreen extends StatefulWidget {
  const MyBusinessProfileScreen({super.key});

  @override
  State<MyBusinessProfileScreen> createState() => _MyBusinessProfileScreenState();
}

class _MyBusinessProfileScreenState extends State<MyBusinessProfileScreen> {
  final SupabaseClient _client = Supabase.instance.client;

  RealtimeChannel? _statsChannel;

  String _businessId = '';
  String _businessName = 'Mi Negocio';
  String _businessAddress = '';
  String? _avatarUrl;

  int _views = 0;
  int _routes = 0;
  int _favorites = 0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    final channel = _statsChannel;
    if (channel != null) {
      _client.removeChannel(channel);
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    _businessId = user.id;

    await Future.wait([
      _loadBusinessProfile(),
      _loadBusinessStats(),
    ]);

    _subscribeRealtime();

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadBusinessProfile() async {
    try {
      final row = await _client
          .from('businesses')
          .select('business_name,address,avatar_url')
          .eq('id', _businessId)
          .maybeSingle();

      if (row == null) return;

      _businessName = (row['business_name'] as String?)?.trim().isNotEmpty == true
          ? row['business_name'] as String
          : _businessName;
      _businessAddress = (row['address'] as String?) ?? '';
      _avatarUrl = row['avatar_url'] as String?;
    } catch (_) {}
  }

  Future<void> _loadBusinessStats() async {
    if (_businessId.isEmpty) return;

    try {
      final negocio = await _client
          .from('negocios')
          .select('id,vistas')
          .eq('propietario_id', _businessId)
          .eq('activo', true)
          .order('creado_en', ascending: false)
          .limit(1)
          .maybeSingle();

      if (negocio == null) {
        _views = 0;
        _routes = 0;
        _favorites = 0;
        return;
      }

      final negocioId = negocio['id'] as String;
      _views = (negocio['vistas'] as num?)?.toInt() ?? 0;

      final statsRows = await _client
          .from('negocio_stats')
          .select('clicks_ruta')
          .eq('negocio_id', negocioId);

      _routes = (statsRows as List)
          .fold<int>(0, (acc, row) => acc + ((row['clicks_ruta'] as num?)?.toInt() ?? 0));

      final favRows = await _client
          .from('negocio_favoritos')
          .select('usuario_id')
          .eq('negocio_id', negocioId);

      _favorites = (favRows as List).length;
    } catch (_) {}
  }

  void _subscribeRealtime() {
    if (_businessId.isEmpty) return;

    final channel = _client.channel('business-dashboard-$_businessId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'negocios',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'propietario_id',
            value: _businessId,
          ),
          callback: (_) async {
            await _refreshAndRebuild();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'negocio_stats',
          callback: (_) async {
            await _refreshAndRebuild();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'negocio_favoritos',
          callback: (_) async {
            await _refreshAndRebuild();
          },
        )
        .subscribe();

    _statsChannel = channel;
  }

  Future<void> _refreshAndRebuild() async {
    await _loadBusinessStats();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          'Mi Negocio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        _LiveBadge(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _BusinessHeader(
                      name: _businessName,
                      address: _businessAddress,
                      avatarUrl: _avatarUrl,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Resumen en Tiempo Real',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Vistas',
                            value: _formatCompact(_views),
                            icon: Icons.visibility,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Rutas',
                            value: _formatCompact(_routes),
                            icon: Icons.alt_route,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Favoritos',
                            value: _formatCompact(_favorites),
                            icon: Icons.favorite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Administracion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ActionButton(
                      title: 'Editar Perfil',
                      icon: Icons.edit_outlined,
                      onTap: () {},
                    ),
                    _ActionButton(
                      title: 'Gestion de Productos',
                      icon: Icons.inventory_2_outlined,
                      onTap: () {},
                    ),
                    _ActionButton(
                      title: 'Promociones Activas',
                      icon: Icons.local_offer_outlined,
                      onTap: () {},
                    ),
                    _ActionButton(
                      title: 'Horarios de Operacion',
                      icon: Icons.schedule_outlined,
                      onTap: () {},
                    ),
                    const SizedBox(height: 28),
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
                              title: const Text(
                                'Cerrar Sesion',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Estas seguro de que quieres cerrar sesion?',
                                style: TextStyle(color: Colors.grey),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Cerrar Sesion',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            final authService = AuthSessionService();
                            await authService.signOut();
                          }
                        },
                        child: const Text(
                          'Cerrar Sesion',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Muul v1.0.0 • Muul 2026',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatCompact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

class _BusinessHeader extends StatelessWidget {
  const _BusinessHeader({
    required this.name,
    required this.address,
    required this.avatarUrl,
  });

  final String name;
  final String address;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
            backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty)
                ? const Icon(Icons.storefront_outlined, color: AppColors.secondary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address.isNotEmpty ? address : 'Sin direccion registrada',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondary),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: AppColors.secondary),
          SizedBox(width: 6),
          Text('Tiempo real', style: TextStyle(color: AppColors.secondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondary, size: 22),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[700]),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main_shell.dart';
import '../providers/badges_provider.dart' as badge_provider;

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        backgroundColor: AppColors.bgApp,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mis Medallas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ── Header con barra decorativa ──
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
                    'Mis Medallas',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Colecciona insignias completando desafíos',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // ── Insignias Desbloqueadas ──
              const Text(
                'Insignias Desbloqueadas',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _UnlockedBadgesSection(ref: ref),
              const SizedBox(height: 32),

              // ── Todas las Insignias Disponibles ──
              const Text(
                'Todas las Insignias',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _AllBadgesSection(ref: ref),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1C1C1E),
        selectedItemColor: const Color(0xFF599265),
        unselectedItemColor: Colors.grey[600],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          Navigator.pop(context);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

/// Sección de insignias desbloqueadas
class _UnlockedBadgesSection extends StatelessWidget {
  final WidgetRef ref;

  const _UnlockedBadgesSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final userBadgesAsync = ref.watch(badge_provider.userBadgesProvider);

    return userBadgesAsync.when(
      data: (userBadges) {
        if (userBadges.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '🎯',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aún no tienes insignias',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa desafíos para desbloquear tus primeras medallas',
                  style: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: userBadges.length,
          itemBuilder: (context, index) {
            final userBadge = userBadges[index];
            return _BadgeCard(
              badge: userBadge.insignia,
              isUnlocked: true,
              unlockedDate: userBadge.obtenidaEn,
            );
          },
        );
      },
      loading: () => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => _ShimmerBadgeCard(),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Error al cargar insignias: ${error.toString()}',
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      ),
    );
  }
}

/// Sección de todas las insignias disponibles
class _AllBadgesSection extends StatelessWidget {
  final WidgetRef ref;

  const _AllBadgesSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final allBadgesAsync = ref.watch(badge_provider.allBadgesProvider);
    final userBadgesAsync = ref.watch(badge_provider.userBadgesProvider);

    return userBadgesAsync.whenData((userBadges) {
      final unlockedIds = userBadges.map((ub) => ub.insigniaId).toSet();

      return allBadgesAsync.when(
        data: (allBadges) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allBadges.length,
            itemBuilder: (context, index) {
              final badge = allBadges[index];
              final isUnlocked = unlockedIds.contains(badge.id);

              return _BadgeCard(
                badge: badge,
                isUnlocked: isUnlocked,
              );
            },
          );
        },
        loading: () => GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          itemBuilder: (context, index) => _ShimmerBadgeCard(),
        ),
        error: (error, stackTrace) => Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Error al cargar insignias: ${error.toString()}',
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ),
      );
    }).when(
      data: (data) => data,
      loading: () => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        itemBuilder: (context, index) => _ShimmerBadgeCard(),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Error al cargar insignias: ${error.toString()}',
          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
        ),
      ),
    );
  }
}

/// Widget de tarjeta de insignia
class _BadgeCard extends StatelessWidget {
  final badge_provider.Badge badge;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  const _BadgeCard({
    required this.badge,
    required this.isUnlocked,
    this.unlockedDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showBadgeDetails(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? AppColors.secondary.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
            gradient: isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  )
                : null,
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de la insignia
            Text(
              isUnlocked ? '🏅' : '🔒',
              style: TextStyle(
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),
            // Nombre de la insignia
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                badge.nombre,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnlocked ? Colors.white : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!isUnlocked) ...[
              const SizedBox(height: 4),
              Text(
                '${badge.requisitoVisitas}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isUnlocked ? '🏅' : '🔒',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          badge.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isUnlocked ? 'Desbloqueada' : 'Bloqueada',
                          style: TextStyle(
                            color: isUnlocked
                                ? AppColors.secondary
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Descripción',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.descripcion,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      '📍 Requisito:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${badge.requisitoVisitas} visitas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnlocked && unlockedDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '✓ Desbloqueada el:',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(unlockedDate!),
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Widget shimmer para carga
class _ShimmerBadgeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

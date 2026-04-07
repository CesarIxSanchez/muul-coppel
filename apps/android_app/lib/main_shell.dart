import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/explore/presentation/screens/home_screen.dart';
import 'features/explore/presentation/screens/explore_screen.dart';
import 'features/map/presentation/map_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

// Provider para controlar globalmente la pestaña activa
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // Las 4 pestañas principales se mantienen vivas con IndexedStack
    const List<Widget> tabs = [
      HomeContent(),   // Home sin sus propios bottom nav
      ExploreScreen(),
      MapScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1C1C1E),
        selectedItemColor: const Color(0xFF599265),
        unselectedItemColor: Colors.grey[600],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
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

// lib/features/map/presentation/widgets/map_controls.dart
import '../providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/tema_provider.dart';

class MapControls extends ConsumerWidget {
  final TemaColors temaColors;
  const MapControls({super.key, required this.temaColors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          icon: Icons.my_location,
          iconColor: temaColors.secondary,
          tooltip: 'Mi ubicación',
          onTap: () =>
              ref.read(mapProvider.notifier).fetchUserLocation(),
        ),
        const SizedBox(height: 8),
        _ControlButton(
          icon: Icons.add,
          iconColor: Colors.white,   // ← antes era bgCard (invisible)
          tooltip: 'Acercar',
          onTap: () async {
            final controller =
                ref.read(mapProvider).value?.mapController;
            if (controller == null) return;
            final zoom = await controller.getCameraState();
            await controller.flyTo(
              CameraOptions(zoom: (zoom.zoom + 1).clamp(0, 22)),
              MapAnimationOptions(duration: 300),
            );
          },
        ),
        const SizedBox(height: 4),
        _ControlButton(
          icon: Icons.remove,
          iconColor: Colors.white,   // ← antes era bgCard (invisible)
          tooltip: 'Alejar',
          onTap: () async {
            final controller =
                ref.read(mapProvider).value?.mapController;
            if (controller == null) return;
            final zoom = await controller.getCameraState();
            await controller.flyTo(
              CameraOptions(zoom: (zoom.zoom - 1).clamp(0, 22)),
              MapAnimationOptions(duration: 300),
            );
          },
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String tooltip;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.iconColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.bgCard,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: Colors.black54,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}
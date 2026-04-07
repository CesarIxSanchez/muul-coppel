import 'package:flutter/material.dart';

class FilterChipStitch extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipStitch({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF599265).withOpacity(0.15)
              : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF599265)
                : Colors.white.withOpacity(0.08),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
            ] else if (icon != null) ...[
              Icon(icon, color: isSelected ? const Color(0xFF599265) : Colors.grey[500], size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF599265) : Colors.grey[300],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

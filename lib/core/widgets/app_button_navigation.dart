import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isMenuOpen,
    required this.onToggleMenu,
  });

  int _visualToReal(int v) => v >= 3 ? v + 1 : v;
  int _realToVisual(int r) => r >= 4 ? r - 1 : r;

  @override
  Widget build(BuildContext context) {
    final bool inSubMenu = currentIndex == 2 || currentIndex == 3;
    final int visualActive = inSubMenu ? -1 : _realToVisual(currentIndex);

    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Inicio'),
      _NavItem(icon: Icons.library_books_rounded, label: 'Biblioteca'),
      null,
      _NavItem(icon: Icons.quiz_rounded, label: 'Exámenes'),
      _NavItem(icon: Icons.person_rounded, label: 'Perfil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            children: List.generate(items.length, (vi) {
              // ── Botón + ──
              if (items[vi] == null) {
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onToggleMenu,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: AnimatedRotation(
                            turns: isMenuOpen ? 0.125 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // ── Tabs normales ──
              final item = items[vi]!;
              final bool selected = vi == visualActive;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(_visualToReal(vi)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textMuted,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTextStyles.caption.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
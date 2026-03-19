import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/profile/presentation/viewmodel/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileViewModel vm = ProfileViewModel();

  @override
  void initState() {
    super.initState();
    // Listen to changes and rebuild when notified
    vm.addListener(_onViewModelChanged);
    // Load profile data when screen initializes
    vm.loadProfileData();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    vm.removeListener(_onViewModelChanged);
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : RefreshIndicator(
                onRefresh: vm.loadProfileData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header con logo
                        Text(
                          "ACADEMIX",
                          style: AppTextStyles.display.copyWith(
                            fontSize: 28,
                            letterSpacing: 1.5,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Avatar + nombre + email + badge
                        Center(
                          child: Column(
                            children: [
                              // Avatar con iniciales
                              Container(
                                width: 90,
                                height: 90,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    vm.initials,
                                    style: AppTextStyles.display.copyWith(
                                      color: AppColors.background,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Nombre
                              Text(
                                vm.fullName,
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.text,
                                  fontSize: 24,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xs),

                              // Email
                              Text(
                                vm.email,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Badge Premium
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: vm.isPremium
                                      ? AppColors.accent.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                  border: Border.all(
                                    color: AppColors.accent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  vm.isPremium ? "USUARIO PREMIUM" : "PLAN FREE",
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Stats: Recursos, Notas, Examenes
                        Row(
                          children: [
                            _StatCard(value: vm.resourcesCount, label: "Recursos"),
                            const SizedBox(width: AppSpacing.md),
                            _StatCard(value: vm.notesCount, label: "Notas"),
                            const SizedBox(width: AppSpacing.md),
                            _StatCard(value: vm.examsCount, label: "Examenes"),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Opciones de menú
                        _MenuOption(
                          icon: Icons.settings_outlined,
                          label: "Configuracion",
                          onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _MenuOption(
                          icon: Icons.star_border_rounded,
                          label: "Mejorar a Premium",
                          onTap: () => Navigator.pushNamed(context, AppRoutes.premium),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _MenuOption(
                          icon: Icons.favorite_border_rounded,
                          label: "Favoritos",
                          onTap: () => Navigator.pushNamed(context, AppRoutes.favorites),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Cerrar sesión — con color de error
                        _MenuOption(
                          icon: Icons.logout_rounded,
                          label: "Cerrar Sesion",
                          onTap: () => vm.onLogout(context),
                          isDestructive: true,
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final int value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.text,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Menu Option ─────────────────────────────────────────────────────────────

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.text;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isDestructive
              ? Border.all(color: AppColors.error.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

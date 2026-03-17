import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/tema/presentation/viewmodel/temas_viewmodel.dart';
import 'package:academix/features/tema/domain/entities/tema_entity.dart';

class TemasScreen extends StatefulWidget {
  const TemasScreen({super.key});

  @override
  State<TemasScreen> createState() => _TemasScreenState();
}

class _TemasScreenState extends State<TemasScreen> {
  final TemasViewModel vm = TemasViewModel();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ACADEMIX",
                    style: AppTextStyles.display.copyWith(
                      fontSize: 28,
                      letterSpacing: 1.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Temas",
                    style: AppTextStyles.h1.copyWith(color: AppColors.primary, fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Explora por materia",
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: vm.temas,
                builder: (context, temasList, _) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (temasList.isEmpty) {
                    return Center(child: Text('No temas disponibles', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: temasList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final tema = temasList[index];
                      return _TemaCard(
                        tema: tema,
                        onTap: () => vm.selectTema(tema),
                        isSelected: vm.selectedTema.value == tema.id,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemaCard extends StatelessWidget {
  final TemaEntity tema;
  final VoidCallback onTap;
  final bool isSelected;

  const _TemaCard({
    required this.tema,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tema.title,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tema.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${tema.subtemas.length} subtemas',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


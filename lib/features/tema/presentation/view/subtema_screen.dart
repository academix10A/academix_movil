import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/tema/presentation/viewmodel/subtema_viewmodel.dart';

class SubtemaScreen extends StatefulWidget {
  final String temaId;
  final String temaTitle;
  const SubtemaScreen({super.key, required this.temaId, required this.temaTitle});

  @override
  State<SubtemaScreen> createState() => _SubtemaScreenState();
}

class _SubtemaScreenState extends State<SubtemaScreen> {
  late final SubtemaViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = SubtemaViewModel()..init(widget.temaId);
  }

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
            // Header
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
                    widget.temaTitle,
                    style: AppTextStyles.h1.copyWith(color: AppColors.primary, fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Subtemas disponibles",
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: vm.subtemas,
                builder: (context, subtemasList, _) {
                  if (vm.isLoading.value) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (subtemasList.isEmpty) {
                    return Center(child: Text('No subtemas disponibles', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: subtemasList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final subtema = subtemasList[index];
                      return _SubtemaCard(
                        subtema: subtema,
                        isSelected: vm.selectedSubtemaId.value == subtema.id,
                        onTap: () => vm.selectSubtema(subtema.id, context),
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

class _SubtemaCard extends StatelessWidget {
  final dynamic subtema; // SubtemaEntity
  final VoidCallback onTap;
  final bool isSelected;

  const _SubtemaCard({
    required this.subtema,
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
              subtema.title,
              style: AppTextStyles.h2.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtema.description,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.book, size: 16, color: AppColors.secondary),
                const SizedBox(width: AppSpacing.xs),
                Text('${subtema.resourceCount} recursos', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.quiz, size: 16, color: AppColors.secondary),
                Text('${subtema.examCount} exámenes', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

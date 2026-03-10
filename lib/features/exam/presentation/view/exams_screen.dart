import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/exam/presentation/viewmodel/exams_viewmodel.dart';
import 'package:academix/features/exam/presentation/widgets/exam_recommended_card.dart';
import 'package:academix/features/exam/presentation/widgets/exam_completed_card.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final ExamsViewModel vm = ExamsViewModel();

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

                  const SizedBox(height: AppSpacing.lg),

                  // Título sección
                  Text(
                    "Examenes",
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    "Evalua tu conocimiento",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Barra de búsqueda
                  TextField(
                    controller: vm.searchController,
                    onSubmitted: vm.onSearch,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    decoration: InputDecoration(
                      hintText: "Buscar por tema, materia",
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundCard,
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Filtros Disponibles / Completados
                  ValueListenableBuilder<ExamFilter>(
                    valueListenable: vm.selectedFilter,
                    builder: (context, selected, _) {
                      return Row(
                        children: ExamFilter.values.map((filter) {
                          final isSelected = selected == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: GestureDetector(
                              onTap: () => vm.selectFilter(filter),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  filter.label,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isSelected
                                        ? AppColors.background
                                        : AppColors.text,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección: Recomendados
                    ValueListenableBuilder<List<ExamItem>>(
                      valueListenable: vm.recommendedExams,
                      builder: (context, exams, _) {
                        if (exams.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recomendados para ti",
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ...exams.map(
                              (exam) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.md),
                                child: ExamRecommendedCard(
                                  exam: exam,
                                  onStart: () => vm.onStartExam(context, exam),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        );
                      },
                    ),

                    // Sección: Completados recientemente
                    ValueListenableBuilder<List<CompletedExamItem>>(
                      valueListenable: vm.completedExams,
                      builder: (context, exams, _) {
                        if (exams.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Completados recientemente",
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ...exams.map(
                              (exam) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.md),
                                child: ExamCompletedCard(
                                  exam: exam,
                                  onTap: () => vm.onCompletedExamTap(context, exam),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

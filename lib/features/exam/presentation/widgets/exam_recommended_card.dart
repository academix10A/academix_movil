import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/exam/presentation/viewmodel/exams_viewmodel.dart';

class ExamRecommendedCard extends StatelessWidget {
  final ExamItem exam;
  final VoidCallback onStart;

  const ExamRecommendedCard({
    super.key,
    required this.exam,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            exam.title,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.text,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Categoría
          Text(
            exam.category,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Meta: preguntas - duración - dificultad
          Text(
            '${exam.questions} preguntas – ${exam.durationMinutes} minutos – ${exam.difficulty}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Botón Comenzar Examen
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                elevation: 0,
              ),
              child: Text(
                'Comenzar Examen',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
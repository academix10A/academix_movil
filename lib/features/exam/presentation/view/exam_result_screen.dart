import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/presentation/viewmodel/exams_viewmodel.dart';

class ExamResultScreen extends StatelessWidget {
  final ExamItem? exam;
  final CompletedExamItem? completedExam;
  final int score;
  final String grade;
  final int correctAnswers;
  final int totalQuestions;

  const ExamResultScreen({
    super.key,
    this.exam,
    this.completedExam,
    required this.score,
    required this.grade,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  // Factory constructor for ExamItem (from taking an exam)
  factory ExamResultScreen.fromExam({
    required ExamItem exam,
    required int score,
    required String grade,
    required int correctAnswers,
    required int totalQuestions,
  }) {
    return ExamResultScreen(
      exam: exam,
      score: score,
      grade: grade,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );
  }

  // Factory constructor for CompletedExamItem (from viewing results)
  factory ExamResultScreen.fromCompletedExam({
    required CompletedExamItem completedExam,
    required int score,
    required String grade,
    required int correctAnswers,
    required int totalQuestions,
  }) {
    return ExamResultScreen(
      completedExam: completedExam,
      score: score,
      grade: grade,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );
  }

  String get _title => exam?.title ?? completedExam?.title ?? '';
  String get _category => exam?.category ?? 'Examen completado';
  String get _difficulty => exam?.difficulty ?? '';
  int get _durationMinutes => exam?.durationMinutes ?? 0;

  @override
  Widget build(BuildContext context) {
    final isPassed = grade == "EXCELENTE" || grade == "APROBADO";
    final wrongAnswers = totalQuestions - correctAnswers;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),

              // Icono de resultado
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isPassed
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.error.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed
                      ? Icons.emoji_events_rounded
                      : Icons.sentiment_dissatisfied_rounded,
                  size: 50,
                  color: isPassed ? AppColors.success : AppColors.error,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Título
              Text(
                isPassed ? "¡Felicidades!" : "¡Inténtalo de nuevo!",
                style: AppTextStyles.display.copyWith(
                  color: AppColors.primary,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subtítulo
              Text(
                "Has completado el examen",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Tarjeta de puntuación
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    // Puntuación circular
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 10,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isPassed ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$score%",
                              style: AppTextStyles.display.copyWith(
                                color: AppColors.text,
                                fontSize: 36,
                              ),
                            ),
                            Text(
                              grade,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isPassed
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Detalles
                    Row(
                      children: [
                        _StatItem(
                          icon: Icons.check_circle_outline_rounded,
                          value: "$correctAnswers",
                          label: "Correctas",
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _StatItem(
                          icon: Icons.cancel_outlined,
                          value: "$wrongAnswers",
                          label: "Incorrectas",
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _StatItem(
                          icon: Icons.quiz_outlined,
                          value: "$totalQuestions",
                          label: "Total",
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Info del examen
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detalles del examen",
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.text,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DetailRow(label: "Título", value: _title),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(label: "Categoría", value: _category),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(label: "Dificultad", value: _difficulty),
                    const SizedBox(height: AppSpacing.sm),
                    _DetailRow(
                      label: "Tiempo",
                      value: "$_durationMinutes minutos",
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Botones de acción
              Row(
                children: [
                  // Volver a exámenes
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        AppNavigator.pushReplacementUnique(
                          context,
                          AppRoutes.main,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.list_alt_rounded,
                              color: AppColors.text,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              "Ver exámenes",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Repetir examen
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        AppNavigator.pushReplacement(
                          context,
                          AppRoutes.examTake,
                          arguments: exam,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.replay_rounded,
                              color: AppColors.background,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              "Repetir",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.text,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


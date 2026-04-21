import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/data/models/exam_models.dart';

/// Pantalla de resultado de un examen.
/// 
/// Solo presenta datos. Sin lógica de negocio (los umbrales de calificación
/// se calcularon en [SubmitExamUseCase] antes de llegar aquí).
class ExamResultScreen extends StatelessWidget {
  final ExamItemModel? exam;
  final int score;
  final String grade;
  final int correctAnswers;
  final int totalQuestions;

  const ExamResultScreen({
    super.key,
    this.exam,
    required this.score,
    required this.grade,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  factory ExamResultScreen.fromArgs(Map<String, dynamic> args) {
    return ExamResultScreen(
      exam: args['exam'] as ExamItemModel?,
      score: args['score'] as int? ?? 0,
      grade: args['grade'] as String? ?? '',
      correctAnswers: args['correctAnswers'] as int? ?? 0,
      totalQuestions: args['totalQuestions'] as int? ?? 0,
    );
  }

  bool get _isPassed => score >= 70;
  int get _wrongAnswers => totalQuestions - correctAnswers;
  String get _title => exam?.title ?? 'Examen';
  String get _category => exam?.category ?? '';
  String get _difficulty => exam?.difficulty ?? '';
  int get _durationMinutes => exam?.durationMinutes ?? 0;

  Color get _scoreColor {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => AppNavigator.pushReplacementUnique(
                        context, AppRoutes.main),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(Icons.close_rounded,
                          color: AppColors.text, size: 22),
                    ),
                  ),
                  const Spacer(),
                  Text('Resultado',
                      style: AppTextStyles.h2.copyWith(color: AppColors.text)),
                  const Spacer(),
                  const SizedBox(width: 42),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _scoreColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPassed
                            ? Icons.emoji_events_rounded
                            : Icons.refresh_rounded,
                        size: 44,
                        color: _scoreColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _isPassed ? '¡Felicidades!' : '¡Sigue practicando!',
                      style: AppTextStyles.display
                          .copyWith(color: AppColors.text, fontSize: 26),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Tarjeta score
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: score / 100,
                                    strokeWidth: 10,
                                    backgroundColor:
                                        AppColors.border.withOpacity(0.3),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            _scoreColor),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$score%',
                                      style: AppTextStyles.display.copyWith(
                                          color: AppColors.text,
                                          fontSize: 34,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            _scoreColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.full),
                                      ),
                                      child: Text(
                                        grade,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color: _scoreColor,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 10,
                                                letterSpacing: 1),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (totalQuestions > 0)
                            Row(
                              children: [
                                _StatBadge(
                                  icon: Icons.check_circle_outline_rounded,
                                  value: '$correctAnswers',
                                  label: 'Correctas',
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _StatBadge(
                                  icon: Icons.cancel_outlined,
                                  value: '$_wrongAnswers',
                                  label: 'Incorrectas',
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _StatBadge(
                                  icon: Icons.quiz_outlined,
                                  value: '$totalQuestions',
                                  label: 'Total',
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Detalles del examen
                    if (_category.isNotEmpty ||
                        _difficulty.isNotEmpty ||
                        _durationMinutes > 0)
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
                            Text('Detalles del examen',
                                style: AppTextStyles.h2.copyWith(
                                    color: AppColors.text, fontSize: 15)),
                            const SizedBox(height: AppSpacing.md),
                            if (_category.isNotEmpty &&
                                _category != 'Examen completado')
                              _DetailRow(
                                  label: 'Categoría', value: _category),
                            if (_difficulty.isNotEmpty &&
                                _difficulty != 'N/A')
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: AppSpacing.sm),
                                child: _DetailRow(
                                    label: 'Dificultad',
                                    value: _difficulty),
                              ),
                            if (_durationMinutes > 0)
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: AppSpacing.sm),
                                child: _DetailRow(
                                    label: 'Duración',
                                    value: '$_durationMinutes min'),
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Botones fijos
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                border:
                    Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => AppNavigator.pushReplacementUnique(
                          context, AppRoutes.main),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list_alt_rounded,
                                color: AppColors.text, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Ver exámenes',
                                style: AppTextStyles.body.copyWith(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (exam != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => AppNavigator.pushReplacement(
                            context, AppRoutes.examTake,
                            arguments: exam),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.replay_rounded,
                                  color: AppColors.background, size: 18),
                              const SizedBox(width: AppSpacing.sm),
                              Text('Repetir',
                                  style: AppTextStyles.body.copyWith(
                                      color: AppColors.background,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBadge(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.h2.copyWith(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
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
        Text(label,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        Text(value,
            style: AppTextStyles.body.copyWith(
                color: AppColors.text, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
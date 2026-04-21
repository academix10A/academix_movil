import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/data/models/exam_models.dart';
import 'package:academix/features/exam/presentation/viewmodel/exam_take_viewmodel.dart';
import 'package:academix/features/exam/exam_dependencies.dart';

class ExamTakeScreen extends StatefulWidget {
  final ExamItemModel exam;

  const ExamTakeScreen({super.key, required this.exam});

  @override
  State<ExamTakeScreen> createState() => _ExamTakeScreenState();
}

class _ExamTakeScreenState extends State<ExamTakeScreen> {
  late final ExamTakeViewModel vm;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      vm = ExamTakeViewModel(
        getExamCompleto: context.examDependencies.getExamCompletoUseCase,
        submitExam: context.examDependencies.submitExamUseCase,
        exam: widget.exam,
      );
      vm.loadExam();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: vm.isLoading,
      builder: (context, loading, _) {
        if (loading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return ValueListenableBuilder<String?>(
          valueListenable: vm.errorMessage,
          builder: (context, error, _) {
            if (error != null || vm.examData == null) {
              return _ErrorBody(error: error, onBack: () => AppNavigator.pop(context));
            }
            return _ExamBody(vm: vm);
          },
        );
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String? error;
  final VoidCallback onBack;

  const _ErrorBody({this.error, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(error ?? 'Error cargando examen', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onBack, child: const Text('Volver')),
          ],
        ),
      ),
    );
  }
}

class _ExamBody extends StatelessWidget {
  final ExamTakeViewModel vm;

  const _ExamBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ExamHeader(vm: vm),
            Expanded(child: _QuestionContent(vm: vm)),
            _NavigationBar(vm: vm),
          ],
        ),
      ),
    );
  }
}

class _ExamHeader extends StatelessWidget {
  final ExamTakeViewModel vm;

  const _ExamHeader({required this.vm});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        final total = vm.preguntas.length;
        final current = vm.currentQuestionIndex.value;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showExitDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.close_rounded, color: AppColors.text, size: 22),
                    ),
                  ),
                  const Spacer(),
                  _TimerBadge(vm: vm),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Text(
                    'Pregunta ${current + 1} de $total',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                  const Spacer(),
                  Text(
                    '${vm.answeredCount}/$total respondidas',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: (current + 1) / total,
                  backgroundColor: AppColors.backgroundCard,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('¿Salir del examen?', style: AppTextStyles.h2.copyWith(color: AppColors.text)),
        content: Text('Si sales ahora, perderás todo el progreso.',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continuar', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppNavigator.pop(context);
            },
            child: Text('Salir', style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final ExamTakeViewModel vm;

  const _TimerBadge({required this.vm});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: vm,
      builder: (_, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: vm.isTimeCritical ? AppColors.error.withOpacity(0.2) : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined,
                size: 18,
                color: vm.isTimeCritical ? AppColors.error : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              vm.formattedTime,
              style: AppTextStyles.body.copyWith(
                color: vm.isTimeCritical ? AppColors.error : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionContent extends StatelessWidget {
  final ExamTakeViewModel vm;

  const _QuestionContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder escucha TODOS los notifyListeners() del vm,
    // incluyendo cuando se selecciona una respuesta.
    return AnimatedBuilder(
      animation: vm,
      builder: (context, _) {
        final question = vm.currentQuestion!;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  vm.exam.category,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                question.contenido,
                style: AppTextStyles.h2.copyWith(color: AppColors.text, fontSize: 20, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.xl),
              ...List.generate(question.opciones.length, (index) {
                final option = question.opciones[index];
                final isSelected = vm.answers[question.idPregunta] == option.idOpcion;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GestureDetector(
                    onTap: () => vm.selectOption(question.idPregunta, option.idOpcion),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: AppTextStyles.body.copyWith(
                                  color: isSelected ? AppColors.background : AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              option.respuesta,
                              style: AppTextStyles.body.copyWith(color: AppColors.text),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

class _NavigationBar extends StatelessWidget {
  final ExamTakeViewModel vm;

  const _NavigationBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: vm.currentQuestionIndex,
      builder: (context, currentIndex, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              if (currentIndex > 0) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: vm.goToPreviousQuestion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back_rounded, color: AppColors.text, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Anterior', style: AppTextStyles.body.copyWith(color: AppColors.text)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: vm.isLastQuestion
                      ? () => vm.submitExam(context)
                      : vm.goToNextQuestion,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          vm.isLastQuestion ? 'Enviar examen' : 'Siguiente',
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.background, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          vm.isLastQuestion ? Icons.send_rounded : Icons.arrow_forward_rounded,
                          color: AppColors.background,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
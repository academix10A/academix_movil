import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/presentation/viewmodel/exams_viewmodel.dart';
import 'package:academix/features/exam/data/datasources/exam_remote_datasource.dart';
import 'package:academix/features/exam/domain/entities/exam_entity.dart';

class ExamTakeScreen extends StatefulWidget {
  final ExamItem exam;

  const ExamTakeScreen({super.key, required this.exam});

  @override
  State<ExamTakeScreen> createState() => _ExamTakeScreenState();
}

class _ExamTakeScreenState extends State<ExamTakeScreen> {
  ExamEntity? _examData;
  bool _loading = true;
  String? _error;
  int _currentQuestion = 0;
  int? _selectedOptionId;
  final Map<int, int> _answers = {}; // id_pregunta -> id_opcion
  late int _remainingSeconds;
  late TextEditingController _timerController;
  final ExamRemoteDataSource _dataSource = ExamRemoteDataSource();

  @override
  void initState() {
    super.initState();
    _loadExamData();
    _remainingSeconds = widget.exam.durationMinutes * 60;
    _timerController = TextEditingController();
    _startTimer();
  }

  Future<void> _loadExamData() async {
    try {
      final data = await _dataSource.getExamCompleto(int.parse(widget.exam.id));
      if (mounted) {
        setState(() {
          _examData = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _loading) return false;
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _submitExam();
        return false;
      }
      return true;
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  Future<void> _submitExam() async {
    if (_examData == null || _answers.length < _examData!.preguntas!.length) {
      // Not all answered, submit anyway
    }

    try {
      final result = await _dataSource.submitExam(
        idExamen: _examData!.idExamen,
        respuestas: _answers,
      );

      final score = result.porcentaje?.round() ?? result.calificacion.round();
      final grade = score >= 90
          ? "EXCELENTE"
          : score >= 70
              ? "APROBADO"
              : "REPROBADO";

      // Navigate to results
      AppNavigator.pushReplacement(
        context,
        AppRoutes.examResult,
        arguments: {
          "exam": widget.exam,
          "score": score,
          "grade": grade,
          "correctAnswers": result.respuestasCorrectas,
          "totalQuestions": result.cantidadPreguntas,
        },
      );
    } catch (e) {
      // Handle error, show dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _examData == null || _examData!.preguntas == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
Icon(Icons.quiz, size: 64, color: AppColors.textMuted),
              const SizedBox(height: AppSpacing.lg),
              Text('Error cargando examen', style: AppTextStyles.h2),
              Text('Datos no disponibles'),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => AppNavigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final preguntas = _examData!.preguntas!;
    final question = preguntas[_currentQuestion];

    final answeredCount = _answers.length;
    final isAnswered = _answers.containsKey(question.idPregunta);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header con progreso y tiempo
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Botón cerrar
                      GestureDetector(
                        onTap: () => _showExitConfirmation(context),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.text,
                            size: 22,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Timer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: _remainingSeconds < 60
                              ? AppColors.error.withOpacity(0.2)
                              : AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: _remainingSeconds < 60
                                  ? AppColors.error
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formattedTime,
                              style: AppTextStyles.body.copyWith(
                                color: _remainingSeconds < 60
                                    ? AppColors.error
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Progreso
                  Row(
                    children: [
                      Text(
                        "Pregunta ${_currentQuestion + 1} de ${preguntas.length}",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "$answeredCount/${preguntas.length} respondidas",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Barra de progreso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: (_currentQuestion + 1) / preguntas.length,
                      backgroundColor: AppColors.backgroundCard,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido de la pregunta
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info del examen
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        widget.exam.category,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Pregunta
                    Text(
                      question.contenido,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.text,
                        fontSize: 20,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Opciones de respuesta
                    ...List.generate(question.opciones.length, (index) {
                      final option = question.opciones[index];
                      final isSelected = _selectedOptionId == option.idOpcion;
                      bool isAnswered = _answers.containsKey(question.idPregunta);
                      int? selectedAnswerId = _answers[question.idPregunta];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: GestureDetector(
                          onTap: isAnswered ? null : () {
                            setState(() {
                              _selectedOptionId = option.idOpcion;
                              _answers[question.idPregunta] = option.idOpcion;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.backgroundCard,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Letra de opción
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.background,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: AppTextStyles.body.copyWith(
                                        color: isSelected
                                            ? AppColors.background
                                            : AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                // Texto de opción
                                Expanded(
                                  child: Text(
                                    option.respuesta,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Navegación entre preguntas
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // Pregunta anterior
                  if (_currentQuestion > 0)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentQuestion--;
                            final prevQuestion = _examData!.preguntas![_currentQuestion];
                            _selectedOptionId = _answers[prevQuestion.idPregunta];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.text,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                "Anterior",
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
                  if (_currentQuestion > 0) const SizedBox(width: AppSpacing.md),
                  // Siguiente / Enviar
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        if (_currentQuestion < preguntas.length - 1) {
                          setState(() {
                            _currentQuestion++;
                            final nextQuestion = preguntas[_currentQuestion];
                            _selectedOptionId = _answers[nextQuestion.idPregunta];


                          });
                        } else {
                          _submitExam();
                        }
                      },
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
                              _currentQuestion < preguntas.length - 1
                                  ? "Siguiente"
                                  : "Enviar examen",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              _currentQuestion < preguntas.length - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.send_rounded,
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
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: Text(
          "¿Salir del examen?",
          style: AppTextStyles.h2.copyWith(color: AppColors.text),
        ),
        content: Text(
          "Si sales ahora, perderás todo el progreso.",
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Continuar",
              style: AppTextStyles.body.copyWith(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppNavigator.pop(context);
            },
            child: Text(
              "Salir",
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}


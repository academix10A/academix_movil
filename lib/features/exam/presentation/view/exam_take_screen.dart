import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/presentation/viewmodel/exams_viewmodel.dart';

class ExamTakeScreen extends StatefulWidget {
  final ExamItem exam;

  const ExamTakeScreen({super.key, required this.exam});

  @override
  State<ExamTakeScreen> createState() => _ExamTakeScreenState();
}

class _ExamTakeScreenState extends State<ExamTakeScreen> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  final Map<int, int> _answers = {};
  late int _remainingSeconds;
  late TextEditingController _timerController;

  // Preguntas de ejemplo
  final List<Map<String, dynamic>> _questions = [
    {
      "question": "¿Cuál es el resultado de la derivada de x²?",
      "options": ["2x", "x", "2", "x²"],
      "correct": 0,
    },
    {
      "question": "¿Qué representa el símbolo '∫' en cálculo?",
      "options": [
        "Una derivada",
        "Una integral",
        "Un límite",
        "Una función"
      ],
      "correct": 1,
    },
    {
      "question": "¿Cuál es la derivada de sen(x)?",
      "options": ["cos(x)", "-cos(x)", "-sen(x)", "tan(x)"],
      "correct": 0,
    },
    {
      "question": "¿Qué es una matriz identidad?",
      "options": [
        "Matriz con puros ceros",
        "Matriz diagonal con unos",
        "Matriz cuadrada",
        "Matriz transpuesta"
      ],
      "correct": 1,
    },
    {
      "question": "¿Cuál es el teorema fundamental del cálculo?",
      "options": [
        "Teorema de Pitágoras",
        "Teorema del valor medio",
        "Relación entre derivada e integral",
        "Teorema de Gauss"
      ],
      "correct": 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.exam.durationMinutes * 60;
    _timerController = TextEditingController();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
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

  void _submitExam() {
    // Calcular puntuación
    int correctAnswers = 0;
    _answers.forEach((questionIndex, answerIndex) {
      if (_questions[questionIndex]["correct"] == answerIndex) {
        correctAnswers++;
      }
    });

    final score = ((correctAnswers / _questions.length) * 100).round();
    final grade = score >= 90
        ? "EXCELENTE"
        : score >= 70
            ? "APROBADO"
            : "REPROBADO";

    // Navegar a resultados
    AppNavigator.pushReplacement(
      context,
      AppRoutes.examResult,
      arguments: {
        "exam": widget.exam,
        "score": score,
        "grade": grade,
        "correctAnswers": correctAnswers,
        "totalQuestions": _questions.length,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

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
                        "Pregunta ${_currentQuestion + 1} de ${_questions.length}",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${_answers.length}/${_questions.length} respondidas",
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
                      value: (_currentQuestion + 1) / _questions.length,
                      backgroundColor: AppColors.backgroundCard,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido de la pregunta
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
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
                      question["question"],
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.text,
                        fontSize: 20,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Opciones de respuesta
                    ...List.generate(
                      (question["options"] as List).length,
                      (index) {
                        final isSelected = _selectedAnswer == index;
                        final isAnswered = _answers.containsKey(_currentQuestion);
                        final isCorrect = index == question["correct"];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAnswer = index;
                                _answers[_currentQuestion] = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.15)
                                    : AppColors.backgroundCard,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
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
                                        style:
                                            AppTextStyles.body.copyWith(
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
                                      question["options"][index],
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                  // Icono de contestada
                                  if (isAnswered && isCorrect)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.success,
                                      size: 22,
                                    )
                                  else if (isAnswered &&
                                      !isCorrect &&
                                      isSelected)
                                    Icon(
                                      Icons.cancel_rounded,
                                      color: AppColors.error,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

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
                            _selectedAnswer = _answers[_currentQuestion];
                          });
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
                        if (_currentQuestion < _questions.length - 1) {
                          setState(() {
                            _currentQuestion++;
                            _selectedAnswer = _answers[_currentQuestion];
                          });
                        } else {
                          _submitExam();
                        }
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
                            Text(
                              _currentQuestion < _questions.length - 1
                                  ? "Siguiente"
                                  : "Enviar examen",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              _currentQuestion < _questions.length - 1
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


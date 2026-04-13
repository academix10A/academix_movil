import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/domain/entities/exam_entity.dart';
import 'package:academix/features/exam/domain/usecases/get_exam_completo_usecase.dart';
import 'package:academix/features/exam/domain/usecases/submit_exam_usecase.dart';
import 'package:academix/features/exam/data/models/exam_models.dart';

/// ViewModel de la pantalla de toma de examen.
/// 
/// Gestiona: carga del examen, navegación entre preguntas,
/// control del temporizador y envío de respuestas.
/// Solo depende de UseCases del dominio.
class ExamTakeViewModel extends ChangeNotifier {
  final GetExamCompletoUseCase _getExamCompleto;
  final SubmitExamUseCase _submitExam;
  final ExamItemModel exam;

  // Estado de carga
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  // Datos del examen
  ExamEntity? _examData;
  ExamEntity? get examData => _examData;

  // Estado de navegación
  final ValueNotifier<int> currentQuestionIndex = ValueNotifier(0);
  final Map<int, int> _answers = {}; // id_pregunta -> id_opcion
  Map<int, int> get answers => Map.unmodifiable(_answers);

  // Timer
  late int remainingSeconds;
  bool _timerActive = false;

  ExamTakeViewModel({
    required GetExamCompletoUseCase getExamCompleto,
    required SubmitExamUseCase submitExam,
    required this.exam,
  })  : _getExamCompleto = getExamCompleto,
        _submitExam = submitExam {
    remainingSeconds = exam.durationMinutes * 60;
  }

  List<QuestionEntity> get preguntas => _examData?.preguntas ?? [];

  QuestionEntity? get currentQuestion {
    if (preguntas.isEmpty) return null;
    return preguntas[currentQuestionIndex.value];
  }

  int? get selectedOptionForCurrent =>
      currentQuestion != null ? _answers[currentQuestion!.idPregunta] : null;

  int get answeredCount => _answers.length;

  bool get isLastQuestion =>
      currentQuestionIndex.value == preguntas.length - 1;

  Future<void> loadExam() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      _examData = await _getExamCompleto(int.parse(exam.id));
      isLoading.value = false;
      _startTimer();
    } on ExamSinPreguntasException {
      errorMessage.value = 'Este examen no tiene preguntas disponibles.';
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error al cargar el examen.';
      isLoading.value = false;
    }
  }

  void selectOption(int idPregunta, int idOpcion) {
    // Regla: no se puede cambiar una respuesta ya guardada
    if (_answers.containsKey(idPregunta)) return;
    _answers[idPregunta] = idOpcion;
    notifyListeners();
  }

  void goToNextQuestion() {
    if (!isLastQuestion) {
      currentQuestionIndex.value++;
    }
  }

  void goToPreviousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  Future<void> submitExam(BuildContext context) async {
    if (_examData == null) return;
    _timerActive = false;

    try {
      final result = await _submitExam(
        SubmitExamParams(
          idExamen: _examData!.idExamen,
          respuestas: _answers,
        ),
      );

      if (context.mounted) {
        AppNavigator.pushReplacement(
          context,
          AppRoutes.examResult,
          arguments: {
            'exam': exam,
            'score': result.scorePercent,
            'grade': result.gradeLabel,
            'correctAnswers': result.entity.respuestasCorrectas,
            'totalQuestions': result.entity.cantidadPreguntas,
          },
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el examen')),
        );
      }
    }
  }

  void _startTimer() {
    _timerActive = true;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_timerActive) return false;
      remainingSeconds--;
      notifyListeners();
      if (remainingSeconds <= 0) {
        _timerActive = false;
        return false;
      }
      return true;
    });
  }

  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isTimeCritical => remainingSeconds < 60;

  @override
  void dispose() {
    _timerActive = false;
    isLoading.dispose();
    errorMessage.dispose();
    currentQuestionIndex.dispose();
    super.dispose();
  }
}
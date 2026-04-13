import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/domain/repositories/exam_repository.dart';
import 'package:academix/features/exam/domain/usecases/get_available_exams_usecase.dart';
import 'package:academix/features/exam/domain/usecases/get_completed_exams_usecase.dart';
import 'package:academix/features/exam/data/models/exam_models.dart';

enum ExamFilter {
  disponibles,
  completados;

  String get label {
    switch (this) {
      case ExamFilter.disponibles:
        return 'Disponibles';
      case ExamFilter.completados:
        return 'Completados';
    }
  }
}

/// ViewModel de la pantalla principal de exámenes.
/// 
/// Solo depende de UseCases del dominio. No conoce DataSources ni Dio.
/// Transforma entidades del dominio en modelos de presentación [ExamItemModel].
class ExamsViewModel {
  final GetAvailableExamsUseCase _getAvailableExams;
  final GetDetailedExamsUseCase _getDetailedExams;

  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<ExamFilter> selectedFilter =
      ValueNotifier(ExamFilter.disponibles);
  final ValueNotifier<String?> selectedSubtema = ValueNotifier(null);
  final ValueNotifier<List<String>> availableSubtemas = ValueNotifier([]);

  final ValueNotifier<List<ExamItemModel>> recommendedExams = ValueNotifier([]);
  final ValueNotifier<List<CompletedExamItemModel>> completedExams =
      ValueNotifier([]);

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<bool> noDesglosPermission = ValueNotifier(false);

  List<ExamItemModel> _allRecommended = [];
  List<CompletedExamItemModel> _allCompleted = [];

  ExamsViewModel({
    required GetAvailableExamsUseCase getAvailableExams,
    required GetDetailedExamsUseCase getDetailedExams,
  })  : _getAvailableExams = getAvailableExams,
        _getDetailedExams = getDetailedExams {
    searchController.addListener(_applyFilter);
    selectedFilter.addListener(_applyFilter);
    selectedSubtema.addListener(_applyFilter);
    loadExams();
  }

  Future<void> loadExams() async {
    isLoading.value = true;
    errorMessage.value = null;
    noDesglosPermission.value = false;

    try {
      // Cargar exámenes disponibles
      final availableEntities = await _getAvailableExams();
      _allRecommended =
          availableEntities.map(ExamItemModel.fromEntity).toList();

      final subtemas = _allRecommended
          .map((e) => e.subtema)
          .where((s) => s != null && s.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList()
        ..sort();
      availableSubtemas.value = subtemas;

      // Cargar exámenes completados (puede requerir permiso premium)
      try {
        final completedEntities = await _getDetailedExams();
        _allCompleted =
            completedEntities.map(CompletedExamItemModel.fromEntity).toList();
      } on PermissionDeniedException {
        _allCompleted = [];
        noDesglosPermission.value = true;
      }

      _applyFilter();
    } catch (_) {
      errorMessage.value = 'Error al cargar exámenes';
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    final query = searchController.text.toLowerCase();
    final filter = selectedFilter.value;
    final subtema = selectedSubtema.value;

    if (filter == ExamFilter.disponibles) {
      recommendedExams.value = _allRecommended.where((e) {
        final matchQuery = query.isEmpty ||
            e.title.toLowerCase().contains(query) ||
            e.category.toLowerCase().contains(query) ||
            (e.subtema?.toLowerCase().contains(query) ?? false);
        final matchSubtema = subtema == null || e.subtema == subtema;
        return matchQuery && matchSubtema;
      }).toList();
      completedExams.value = [];
    } else {
      recommendedExams.value = [];
      completedExams.value = _allCompleted.where((e) {
        return query.isEmpty || e.title.toLowerCase().contains(query);
      }).toList();
    }
  }

  void selectFilter(ExamFilter filter) {
    selectedFilter.value = filter;
    selectedSubtema.value = null;
  }

  void selectSubtema(String? subtema) {
    selectedSubtema.value = subtema;
  }

  void onSearch(String _) => _applyFilter();

  void onStartExam(BuildContext context, ExamItemModel exam) {
    AppNavigator.push(context, AppRoutes.examTake, arguments: exam);
  }

  void onCompletedExamTap(BuildContext context, CompletedExamItemModel exam) {
    final tempExam = ExamItemModel(
      id: exam.examId,
      title: exam.title,
      category: 'Examen completado',
      questions: exam.questions,
      durationMinutes: 0,
      difficulty: 'N/A',
    );

    AppNavigator.push(
      context,
      AppRoutes.examResult,
      arguments: {
        'exam': tempExam,
        'score': exam.score,
        'grade': exam.grade,
        'correctAnswers': exam.correctAnswers,
        'totalQuestions': exam.questions,
      },
    );
  }

  void dispose() {
    searchController.dispose();
    selectedFilter.dispose();
    selectedSubtema.dispose();
    availableSubtemas.dispose();
    recommendedExams.dispose();
    completedExams.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    noDesglosPermission.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/domain/entities/exam_entity.dart';
import 'package:academix/features/exam/data/datasources/exam_remote_datasource.dart';

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

class ExamItem {
  final String id;
  final String title;
  final String category;
  final int questions;
  final int durationMinutes;
  final String difficulty;

  const ExamItem({
    required this.id,
    required this.title,
    required this.category,
    required this.questions,
    required this.durationMinutes,
    required this.difficulty,
  });

  // Mapper desde entity
  factory ExamItem.fromEntity(ExamEntity entity) {
    return ExamItem(
      id: entity.idExamen.toString(),
      title: entity.titulo,
      category: entity.nombreCreador ?? 'Examen',
      questions: entity.cantidadPreguntas,
      durationMinutes: entity.duracionMinutos,
      difficulty: entity.difficulty,
    );
  }
}

class CompletedExamItem {
  final String id;
  final String title;
  final int questions;
  final String timeAgo;
  final int score; // porcentaje 0-100
  final String grade; // APROBADO, EXCELENTE, REPROBADO, etc.

  const CompletedExamItem({
    required this.id,
    required this.title,
    required this.questions,
    required this.timeAgo,
    required this.score,
    required this.grade,
  });

  // Mapper desde entity
  factory CompletedExamItem.fromEntity(CompletedExamEntity entity) {
    return CompletedExamItem(
      id: entity.idIntento.toString(),
      title: entity.examTitle,
      questions: entity.cantidadPreguntas,
      timeAgo: entity.dateCompleted,
      score: entity.calificacion.round(),
      grade: entity.aprobo ? 'APROBADO' : 'REPROBADO',
    );
  }
}

class ExamsViewModel {
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<ExamFilter> selectedFilter =
      ValueNotifier<ExamFilter>(ExamFilter.disponibles);

  final ValueNotifier<List<ExamItem>> recommendedExams =
      ValueNotifier<List<ExamItem>>([]);
  final ValueNotifier<List<CompletedExamItem>> completedExams =
      ValueNotifier<List<CompletedExamItem>>([]);

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  final ExamRemoteDataSource _remoteDataSource = ExamRemoteDataSource();
  
  List<ExamItem> _allRecommended = [];
  List<CompletedExamItem> _allCompleted = [];

  ExamsViewModel() {
    _applyFilter();
    searchController.addListener(_applyFilter);
    selectedFilter.addListener(_applyFilter);
    loadExams();
  }

  Future<void> loadExams() async {
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      // Cargar exámenes disponibles
      final availableEntities = await _remoteDataSource.getAvailableExams();
      _allRecommended = availableEntities.map((e) => ExamItem.fromEntity(e)).toList();
      
      // Cargar exámenes completados
      final completedEntities = await _remoteDataSource.getCompletedExams();
      _allCompleted = completedEntities.map((e) => CompletedExamItem.fromEntity(e)).toList();
      
      _applyFilter();
    } catch (e) {
      errorMessage.value = 'Error al cargar exámenes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    final query = searchController.text.toLowerCase();
    final filter = selectedFilter.value;

    if (filter == ExamFilter.disponibles) {
      recommendedExams.value = _allRecommended.where((e) {
        return query.isEmpty ||
            e.title.toLowerCase().contains(query) ||
            e.category.toLowerCase().contains(query);
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
  }

  void onSearch(String query) {
    _applyFilter();
  }

  void onStartExam(BuildContext context, ExamItem exam) {
    AppNavigator.push(
      context,
      AppRoutes.examTake,
      arguments: exam,
    );
  }

  void onCompletedExamTap(BuildContext context, CompletedExamItem exam) {
    // Create a temporary ExamItem from CompletedExamItem for the result screen
    final tempExam = ExamItem(
      id: exam.id,
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
        "exam": tempExam,
        "completedExam": exam,
        "score": exam.score,
        "grade": exam.grade,
        "correctAnswers": (exam.questions * exam.score / 100).round(),
        "totalQuestions": exam.questions,
      },
    );
  }

  void dispose() {
    searchController.dispose();
    selectedFilter.dispose();
    recommendedExams.dispose();
    completedExams.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}


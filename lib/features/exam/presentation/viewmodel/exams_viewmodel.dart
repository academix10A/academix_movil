import 'package:dio/dio.dart';
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
  final String? subtema;

  const ExamItem({
    required this.id,
    required this.title,
    required this.category,
    required this.questions,
    required this.durationMinutes,
    required this.difficulty,
    this.subtema,
  });

  factory ExamItem.fromEntity(ExamEntity entity) {
    return ExamItem(
      id: entity.idExamen.toString(),
      title: entity.titulo,
      category: entity.nombreCreador ?? 'Examen',
      questions: entity.cantidadPreguntas,
      durationMinutes: entity.duracionMinutos,
      difficulty: entity.difficulty,
      subtema: entity.nombreSubtema,
    );
  }
}

class CompletedExamItem {
  final String id;        // id_intento — solo para identificar la card
  final String examId;    // id_examen  — para poder repetir el examen
  final String title;
  final int questions;
  final String timeAgo;
  final int score;        // porcentaje 0-100
  final String grade;
  final int correctAnswers;

  const CompletedExamItem({
    required this.id,
    required this.examId,
    required this.title,
    required this.questions,
    required this.timeAgo,
    required this.score,
    required this.grade,
    required this.correctAnswers,
  });

  factory CompletedExamItem.fromEntity(CompletedExamEntity entity) {
    // porcentaje viene del endpoint /detalles (0-100)
    // calificacion viene en escala 0-10, así que usamos porcentaje si está disponible
    final scoreValue = (entity.porcentaje != null && entity.porcentaje! > 0)
        ? entity.porcentaje!.round()
        : (entity.calificacion * 10).round();

    return CompletedExamItem(
      id: entity.idIntento.toString(),
      examId: entity.idExamen.toString(),
      title: entity.examTitle,
      questions: entity.cantidadPreguntas,
      timeAgo: entity.dateCompleted,
      score: scoreValue,
      grade: entity.aprobo ? 'APROBADO' : 'REPROBADO',
      correctAnswers: entity.respuestasCorrectas,
    );
  }
}

class ExamsViewModel {
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<ExamFilter> selectedFilter =
      ValueNotifier<ExamFilter>(ExamFilter.disponibles);
  final ValueNotifier<String?> selectedSubtema = ValueNotifier<String?>(null);
  final ValueNotifier<List<String>> availableSubtemas =
      ValueNotifier<List<String>>([]);

  final ValueNotifier<List<ExamItem>> recommendedExams =
      ValueNotifier<List<ExamItem>>([]);
  final ValueNotifier<List<CompletedExamItem>> completedExams =
      ValueNotifier<List<CompletedExamItem>>([]);

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> noDesglosPermission = ValueNotifier<bool>(false);

  final ExamRemoteDataSource _remoteDataSource = ExamRemoteDataSource();

  List<ExamItem> _allRecommended = [];
  List<CompletedExamItem> _allCompleted = [];

  ExamsViewModel() {
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
      final availableEntities = await _remoteDataSource.getAvailableExams();
      _allRecommended =
          availableEntities.map((e) => ExamItem.fromEntity(e)).toList();

      final subtemas = _allRecommended
          .map((e) => e.subtema)
          .where((s) => s != null && s.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList()
        ..sort();
      availableSubtemas.value = subtemas;

      try {
        final completedEntities = await _remoteDataSource.getDetailedExams();
        _allCompleted = completedEntities
            .map((e) => CompletedExamItem.fromEntity(e))
            .toList();
      } on DioException catch (e) {
        if (e.response?.statusCode == 403) {
          _allCompleted = [];
          noDesglosPermission.value = true;
        } else {
          rethrow;
        }
      }

      _applyFilter();
    } catch (e) {
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
    // Usamos examId (id_examen) para que el botón "Repetir" funcione correctamente
    final tempExam = ExamItem(
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
import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/data/datasources/exam_remote_datasource.dart';
import 'package:academix/features/exam/domain/entities/exam_entity.dart';
import 'package:academix/features/exam/presentation/viewmodel/exams_viewmodel.dart';

/// Representa un intento individual dentro de un grupo
class ExamIntentoItem {
  final int idIntento;
  final int idExamen;
  final int numero;
  final int score; // porcentaje 0-100
  final String grade;
  final String timeAgo;
  final int correctAnswers;
  final int totalQuestions;
  final String examTitle;

  const ExamIntentoItem({
    required this.idIntento,
    required this.idExamen,
    required this.numero,
    required this.score,
    required this.grade,
    required this.timeAgo,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.examTitle,
  });
}

/// Agrupa múltiples intentos del mismo examen
class ExamHistoryGroup {
  final int idExamen;
  final String title;
  final String? subtema;
  final List<ExamIntentoItem> intentos;

  const ExamHistoryGroup({
    required this.idExamen,
    required this.title,
    this.subtema,
    required this.intentos,
  });

  int get bestScore =>
      intentos.map((i) => i.score).reduce((a, b) => a > b ? a : b);
}

class ExamHistoryViewModel extends ChangeNotifier {
  final ValueNotifier<List<ExamHistoryGroup>> historyGroups =
      ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  final ExamRemoteDataSource _remote = ExamRemoteDataSource();

  ExamHistoryViewModel();

  Future<void> loadHistory() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Obtener todos los intentos del usuario
      final completedEntities = await _remote.getCompletedExams();

      // Agrupar por id_examen
      final Map<int, List<CompletedExamEntity>> grouped = {};
      for (final entity in completedEntities) {
        grouped.putIfAbsent(entity.idExamen, () => []).add(entity);
      }

      // Para cada examen con más de 1 intento, intentar obtener el detalle completo
      // (el endpoint /mis-intentos requiere HISTORIAL premium)
      final List<ExamHistoryGroup> groups = [];

      for (final entry in grouped.entries) {
        final idExamen = entry.key;
        final entityList = entry.value;

        // Intentar obtener detalle de intentos (premium)
        List<ExamIntentoItem> intentoItems = [];

        try {
          final misIntentos = await _remote.getMisIntentos(idExamen);
          intentoItems = misIntentos.intentos.map((i) {
            final score = (i.porcentaje).round();
            return ExamIntentoItem(
              idIntento: i.idIntento,
              idExamen: idExamen,
              numero: i.numeroIntento,
              score: score,
              grade: score >= 70 ? 'APROBADO' : 'REPROBADO',
              timeAgo: _formatDate(i.fecha),
              correctAnswers: 0, // No retorna este dato en mis-intentos
              totalQuestions: 0,
              examTitle: misIntentos.tituloExamen,
            );
          }).toList();

          groups.add(ExamHistoryGroup(
            idExamen: idExamen,
            title: misIntentos.tituloExamen,
            intentos: intentoItems,
          ));
        } catch (_) {
          // Si no tiene acceso premium a mis-intentos, usar los datos básicos
          intentoItems = entityList.asMap().entries.map((e) {
            final idx = e.key + 1;
            final entity = e.value;
            final score = entity.calificacion.round();
            return ExamIntentoItem(
              idIntento: entity.idIntento,
              idExamen: entity.idExamen,
              numero: idx,
              score: score,
              grade: entity.aprobo ? 'APROBADO' : 'REPROBADO',
              timeAgo: entity.dateCompleted,
              correctAnswers: entity.respuestasCorrectas,
              totalQuestions: entity.cantidadPreguntas,
              examTitle: entity.examTitle,
            );
          }).toList();

          groups.add(ExamHistoryGroup(
            idExamen: idExamen,
            title: entityList.first.examTitle,
            intentos: intentoItems,
          ));
        }
      }

      // Ordenar por el intento más reciente primero
      historyGroups.value = groups;
    } catch (e) {
      errorMessage.value = 'Error al cargar historial';
    } finally {
      isLoading.value = false;
    }
  }

  /// Navegar al resultado de un intento específico
  void onTapIntento(
    BuildContext context,
    ExamHistoryGroup group,
    ExamIntentoItem intento,
  ) {
    final tempExam = ExamItem(
      id: group.idExamen.toString(),
      title: group.title,
      category: group.subtema ?? 'Examen completado',
      questions: intento.totalQuestions,
      durationMinutes: 0,
      difficulty: 'N/A',
    );

    AppNavigator.push(
      context,
      AppRoutes.examResult,
      arguments: {
        "exam": tempExam,
        "score": intento.score,
        "grade": intento.grade,
        "correctAnswers": intento.correctAnswers,
        "totalQuestions": intento.totalQuestions,
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 30) return 'Hace más de un mes';
    if (diff.inDays > 0) return 'Hace ${diff.inDays} días';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} horas';
    return 'Hoy';
  }

  @override
  void dispose() {
    historyGroups.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    super.dispose();
  }
}
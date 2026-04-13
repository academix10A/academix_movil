import 'package:academix/features/exam/domain/entities/exam_entity.dart';

/// Modelo de presentación de un examen disponible.
/// 
/// Transforma [ExamEntity] (dominio) en un objeto liviano
/// optimizado para ser consumido por la UI.
class ExamItemModel {
  final String id;
  final String title;
  final String category;
  final int questions;
  final int durationMinutes;
  final String difficulty;
  final String? subtema;

  const ExamItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.questions,
    required this.durationMinutes,
    required this.difficulty,
    this.subtema,
  });

  factory ExamItemModel.fromEntity(ExamEntity entity) {
    return ExamItemModel(
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

/// Modelo de presentación de un examen completado (intento individual).
class CompletedExamItemModel {
  final String id;       // id_intento
  final String examId;   // id_examen (para poder repetir)
  final String title;
  final int questions;
  final String timeAgo;
  final int score;       // porcentaje 0–100
  final String grade;
  final int correctAnswers;

  const CompletedExamItemModel({
    required this.id,
    required this.examId,
    required this.title,
    required this.questions,
    required this.timeAgo,
    required this.score,
    required this.grade,
    required this.correctAnswers,
  });

  factory CompletedExamItemModel.fromEntity(CompletedExamEntity entity) {
    final scoreValue = (entity.porcentaje != null && entity.porcentaje! > 0)
        ? entity.porcentaje!.round()
        : (entity.calificacion * 10).round();

    return CompletedExamItemModel(
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

/// Modelo de presentación para un intento individual dentro del historial agrupado.
class ExamIntentoItemModel {
  final int idIntento;
  final int idExamen;
  final int numero;
  final int score;
  final String grade;
  final String timeAgo;
  final int correctAnswers;
  final int totalQuestions;
  final String examTitle;

  const ExamIntentoItemModel({
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

/// Modelo de presentación para un grupo de intentos del mismo examen.
class ExamHistoryGroupModel {
  final int idExamen;
  final String title;
  final String? subtema;
  final List<ExamIntentoItemModel> intentos;

  const ExamHistoryGroupModel({
    required this.idExamen,
    required this.title,
    this.subtema,
    required this.intentos,
  });

  int get bestScore =>
      intentos.map((i) => i.score).reduce((a, b) => a > b ? a : b);
}
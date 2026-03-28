import '../../domain/entities/exam_entity.dart';

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

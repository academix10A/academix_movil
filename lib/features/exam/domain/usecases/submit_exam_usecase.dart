import '../entities/exam_entity.dart';
import '../repositories/exam_repository.dart';

/// Parámetros de entrada para el caso de uso de envío de examen.
class SubmitExamParams {
  final int idExamen;
  final Map<int, int> respuestas; // id_pregunta -> id_opcion

  const SubmitExamParams({
    required this.idExamen,
    required this.respuestas,
  });
}

/// Resultado del envío de un examen, con lógica de calificación aplicada.
class ExamSubmitResult {
  final CompletedExamEntity entity;
  final int scorePercent;   // 0-100
  final String gradeLabel;  // "EXCELENTE" | "APROBADO" | "REPROBADO"
  final bool passed;

  const ExamSubmitResult({
    required this.entity,
    required this.scorePercent,
    required this.gradeLabel,
    required this.passed,
  });
}

/// Caso de uso: Enviar las respuestas de un examen y obtener el resultado calificado.
/// 
/// La lógica de negocio de calificación (umbrales, etiquetas) vive aquí,
/// no en el ViewModel ni en el DataSource.
class SubmitExamUseCase {
  final ExamRepository _repository;

  const SubmitExamUseCase(this._repository);

  Future<ExamSubmitResult> call(SubmitExamParams params) async {
    final entity = await _repository.submitExam(
      idExamen: params.idExamen,
      respuestas: params.respuestas,
    );

    final score = entity.porcentaje?.round() ?? entity.calificacion.round();
    final gradeLabel = _resolveGradeLabel(score);
    final passed = score >= 70;

    return ExamSubmitResult(
      entity: entity,
      scorePercent: score,
      gradeLabel: gradeLabel,
      passed: passed,
    );
  }

  /// Regla de negocio: etiquetas de calificación según rango de puntaje.
  String _resolveGradeLabel(int score) {
    if (score >= 90) return 'EXCELENTE';
    if (score >= 70) return 'APROBADO';
    return 'REPROBADO';
  }
}
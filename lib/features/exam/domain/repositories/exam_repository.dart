import '../entities/exam_entity.dart';

/// Contrato que define las operaciones disponibles del módulo de exámenes.
/// La capa de dominio solo conoce esta abstracción, nunca la implementación.
abstract class ExamRepository {
  /// Obtiene todos los exámenes disponibles para el usuario.
  Future<List<ExamEntity>> getAvailableExams();

  /// Obtiene un examen básico por ID (sin preguntas).
  Future<ExamEntity> getExamById(int id);

  /// Obtiene un examen completo con todas sus preguntas y opciones.
  Future<ExamEntity> getExamCompleto(int id);

  /// Obtiene los exámenes completados por el usuario (básico, sin desglose).
  Future<List<CompletedExamEntity>> getCompletedExams();

  /// Obtiene los exámenes completados con desglose completo (requiere beneficio DESGLOSE).
  /// Lanza [PermissionDeniedException] si el usuario no tiene el beneficio.
  Future<List<CompletedExamEntity>> getDetailedExams();

  /// Obtiene todos los intentos del usuario para un examen específico (requiere beneficio HISTORIAL).
  /// Lanza [PermissionDeniedException] si el usuario no tiene el beneficio.
  Future<ExamMisIntentosEntity> getMisIntentos(int idExamen);

  /// Envía las respuestas del usuario y obtiene el resultado del examen.
  Future<CompletedExamEntity> submitExam({
    required int idExamen,
    required Map<int, int> respuestas,
  });
}

/// Excepción lanzada cuando el usuario no tiene permiso para una operación premium.
class PermissionDeniedException implements Exception {
  final String message;
  const PermissionDeniedException([this.message = 'Permiso denegado']);

  @override
  String toString() => 'PermissionDeniedException: $message';
}
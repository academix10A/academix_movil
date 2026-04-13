import '../entities/exam_entity.dart';
import '../repositories/exam_repository.dart';

/// Caso de uso: Obtener un examen completo con preguntas y opciones.
/// 
/// Usado por la pantalla de toma de examen antes de iniciar.
class GetExamCompletoUseCase {
  final ExamRepository _repository;

  const GetExamCompletoUseCase(this._repository);

  Future<ExamEntity> call(int idExamen) async {
    final exam = await _repository.getExamCompleto(idExamen);

    // Regla de negocio: el examen debe tener preguntas para poder tomarse
    if (exam.preguntas == null || exam.preguntas!.isEmpty) {
      throw const ExamSinPreguntasException();
    }

    return exam;
  }
}

class ExamSinPreguntasException implements Exception {
  const ExamSinPreguntasException();

  @override
  String toString() => 'ExamSinPreguntasException: El examen no tiene preguntas disponibles';
}
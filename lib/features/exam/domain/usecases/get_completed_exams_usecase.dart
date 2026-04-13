import '../entities/exam_entity.dart';
import '../repositories/exam_repository.dart';

/// Caso de uso: Obtener exámenes completados con desglose (requiere beneficio DESGLOSE).
/// 
/// Si el usuario no tiene el beneficio, el repositorio lanzará [PermissionDeniedException].
class GetDetailedExamsUseCase {
  final ExamRepository _repository;

  const GetDetailedExamsUseCase(this._repository);

  Future<List<CompletedExamEntity>> call() {
    return _repository.getDetailedExams();
  }
}

/// Caso de uso: Obtener exámenes completados sin desglose (básico, sin restricción premium).
class GetCompletedExamsUseCase {
  final ExamRepository _repository;

  const GetCompletedExamsUseCase(this._repository);

  Future<List<CompletedExamEntity>> call() {
    return _repository.getCompletedExams();
  }
}
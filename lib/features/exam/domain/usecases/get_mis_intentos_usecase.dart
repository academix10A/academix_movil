import '../entities/exam_entity.dart';
import '../repositories/exam_repository.dart';

/// Caso de uso: Obtener todos los intentos del usuario para un examen (requiere beneficio HISTORIAL).
/// 
/// Si el usuario no tiene el beneficio, el repositorio lanzará [PermissionDeniedException].
class GetMisIntentosUseCase {
  final ExamRepository _repository;

  const GetMisIntentosUseCase(this._repository);

  Future<ExamMisIntentosEntity> call(int idExamen) {
    return _repository.getMisIntentos(idExamen);
  }
}
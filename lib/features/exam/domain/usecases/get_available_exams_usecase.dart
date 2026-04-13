import '../entities/exam_entity.dart';
import '../repositories/exam_repository.dart';

/// Caso de uso: Obtener exámenes disponibles para el usuario.
/// 
/// Encapsula la lógica de negocio: solo se retornan exámenes activos.
class GetAvailableExamsUseCase {
  final ExamRepository _repository;

  const GetAvailableExamsUseCase(this._repository);

  Future<List<ExamEntity>> call() async {
    final exams = await _repository.getAvailableExams();
    // Regla de negocio: solo mostrar exámenes activos
    return exams.where((e) => e.estaActivo).toList();
  }
}
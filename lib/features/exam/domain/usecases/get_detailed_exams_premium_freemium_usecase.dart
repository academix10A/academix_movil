import 'package:academix/features/exam/domain/entities/exam_entity.dart';
import 'package:academix/features/exam/domain/repositories/exam_repository.dart';

/// Obtiene el historial detallado de exámenes (requiere beneficio DESGLOSE).
/// Lanza [PermissionDeniedException] si el usuario es freemium.
class GetDetailedExamsPremiumFreemiumUseCase {
  final ExamRepository _repository;

  const GetDetailedExamsPremiumFreemiumUseCase(this._repository);

  Future<List<CompletedExamEntity>> call() {
    return _repository.getDetailedExams();
  }
}
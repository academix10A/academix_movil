import '../../domain/repositories/exam_repository.dart';
import '../../domain/entities/exam_entity.dart';
import '../datasources/exam_remote_datasource.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDataSource remote;

  ExamRepositoryImpl(this.remote);

  @override
  Future<List<ExamEntity>> getAvailableExams() {
    return remote.getAvailableExams();
  }

  @override
  Future<ExamEntity> getExamById(int id) {
    return remote.getExamById(id);
  }

  @override
  Future<ExamEntity> getExamCompleto(int id) {
    return remote.getExamCompleto(id);
  }

  @override
  Future<List<CompletedExamEntity>> getCompletedExams() {
    return remote.getCompletedExams();
  }

  @override
  Future<CompletedExamEntity> submitExam(int idExamen, Map<int, int> respuestas) {
    return remote.submitExam(idExamen: idExamen, respuestas: respuestas);
  }
}


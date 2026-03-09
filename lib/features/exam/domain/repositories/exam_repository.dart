import '../entities/exam_entity.dart';

abstract class ExamRepository {
  Future<List<ExamEntity>> getAvailableExams();
  Future<ExamEntity> getExamById(int id);
  Future<List<CompletedExamEntity>> getCompletedExams();
  Future<CompletedExamEntity> submitExam(int idExamen, Map<int, int> respuestas);
}


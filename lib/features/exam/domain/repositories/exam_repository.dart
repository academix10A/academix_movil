import '../entities/exam_entity.dart';

abstract class ExamRepository {
  Future<List<ExamEntity>> getAvailableExams();
  Future<ExamEntity> getExamById(int id);
  Future<ExamEntity> getExamCompleto(int id); // New
  Future<List<CompletedExamEntity>> getCompletedExams();
  Future<CompletedExamEntity> submitExam(int idExamen, Map<int, int> respuestas);
}


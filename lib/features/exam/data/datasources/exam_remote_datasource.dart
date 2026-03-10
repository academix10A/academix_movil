import '../../../../core/network/dio_client.dart';
import '../../domain/entities/exam_entity.dart';

class ExamRemoteDataSource {
  Future<List<ExamEntity>> getAvailableExams() async {
    final response = await DioClient.dio.get('/examen/');

    final List data = response.data;

    return data.map((e) => ExamEntity.fromJson(e)).toList();
  }

  Future<ExamEntity> getExamById(int id) async {
    final response = await DioClient.dio.get('/examen/$id');

    return ExamEntity.fromJson(response.data);
  }

  Future<List<CompletedExamEntity>> getCompletedExams() async {
    final response = await DioClient.dio.get('/intento/usuario');

    final List data = response.data;

    return data.map((e) => CompletedExamEntity.fromJson(e)).toList();
  }

  Future<CompletedExamEntity> submitExam({
    required int idExamen,
    required Map<int, int> respuestas,
  }) async {
    final response = await DioClient.dio.post('/intento/', data: {
      'id_examen': idExamen,
      'respuestas': respuestas,
    });

    return CompletedExamEntity.fromJson(response.data);
  }
}


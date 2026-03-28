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

  /// New: Fetch complete exam with questions/options for taking exam
  Future<ExamEntity> getExamCompleto(int id) async {
    final response = await DioClient.dio.get('/examen/$id/completo');

    return ExamEntity.fromCompletoJson(response.data);
  }

  Future<List<CompletedExamEntity>> getCompletedExams() async {
    final response = await DioClient.dio.get('/intento/usuario');

    final List data = response.data;

    return data.map((e) => CompletedExamEntity.fromJson(e)).toList();
  }

  Future<CompletedExamEntity> submitExam({
    required int idExamen,
    required Map<int, int> respuestas, // id_pregunta -> id_opcion
  }) async {
    // Get current user ID
    final userResp = await DioClient.dio.get('/usuarios/me');
    final idUsuario = userResp.data['id_usuario'];

    final payload = {
      'id_examen': idExamen,
      'id_usuario': idUsuario,
      'respuestas': respuestas.entries.map((entry) => {
        'id_pregunta': entry.key,
        'id_opcion': entry.value,
      }).toList(),
    };

    final response = await DioClient.dio.post('/examen/submit', data: payload);

    return CompletedExamEntity.fromSubmitJson(response.data);
  }
}


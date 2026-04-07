// import '../../../../core/network/dio_client.dart';
// import '../../domain/entities/exam_entity.dart';

// class ExamRemoteDataSource {
//   Future<List<ExamEntity>> getAvailableExams() async {
//     final response = await DioClient.dio.get('/examen/');
//     final List data = response.data;
//     return data.map((e) => ExamEntity.fromJson(e)).toList();
//   }

//   Future<ExamEntity> getExamById(int id) async {
//     final response = await DioClient.dio.get('/examen/$id');
//     return ExamEntity.fromJson(response.data);
//   }

//   Future<ExamEntity> getExamCompleto(int id) async {
//     final response = await DioClient.dio.get('/examen/$id/completo');
//     return ExamEntity.fromCompletoJson(response.data);
//   }

//   Future<List<CompletedExamEntity>> getCompletedExams() async {
//     final userResp = await DioClient.dio.get('/usuarios/me');
//     final idUsuario = userResp.data['id_usuario'];
//     final response = await DioClient.dio.get('/examen/usuario/$idUsuario/realizados');
//     final List data = response.data;
//     return data.map((e) => CompletedExamEntity.fromJson(e)).toList();
//   }

//   Future<List<CompletedExamEntity>> getDetailedExams() async {
//     final userResp = await DioClient.dio.get('/usuarios/me');
//     final idUsuario = userResp.data['id_usuario'];
//     final response = await DioClient.dio.get('/examen/usuario/$idUsuario/detalles');
//     final List data = response.data;
//     return data.map((e) => CompletedExamEntity.fromJson(e)).toList();
//   }

//   /// Obtiene todos los intentos de un examen específico (premium: HISTORIAL)
//   Future<ExamMisIntentosEntity> getMisIntentos(int idExamen) async {
//     final response = await DioClient.dio.get('/examen/$idExamen/mis-intentos');
//     return ExamMisIntentosEntity.fromJson(response.data);
//   }

//   Future<CompletedExamEntity> submitExam({
//     required int idExamen,
//     required Map<int, int> respuestas,
//   }) async {
//     final userResp = await DioClient.dio.get('/usuarios/me');
//     final idUsuario = userResp.data['id_usuario'];

//     final payload = {
//       'id_examen': idExamen,
//       'id_usuario': idUsuario,
//       'respuestas': respuestas.entries
//           .map((entry) => {
//                 'id_pregunta': entry.key,
//                 'id_opcion': entry.value,
//               })
//           .toList(),
//     };

//     final response = await DioClient.dio.post('/examen/submit', data: payload);
//     return CompletedExamEntity.fromSubmitJson(response.data);
//   }
// }

import 'package:academix/core/network/dio_client.dart';
import 'package:academix/features/exam/domain/entities/exam_entity.dart';

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

  Future<ExamEntity> getExamCompleto(int id) async {
    final response = await DioClient.dio.get('/examen/$id/completo');
    return ExamEntity.fromCompletoJson(response.data);
  }

  Future<List<CompletedExamEntity>> getCompletedExams() async {
    final userResp = await DioClient.dio.get('/usuarios/me');
    final idUsuario = userResp.data['id_usuario'];
    final response = await DioClient.dio
        .get('/examen/usuario/$idUsuario/realizados');
    final List data = response.data;
    return data.map((e) => CompletedExamEntity.fromJson(e)).toList();
  }

  /// Exámenes completados con desglose completo.
  /// Lanza DioException con status 403 si el usuario no tiene el beneficio DESGLOSE.
  Future<List<CompletedExamEntity>> getDetailedExams() async {
    final userResp = await DioClient.dio.get('/usuarios/me');
    final idUsuario = userResp.data['id_usuario'];
    final response = await DioClient.dio
        .get('/examen/usuario/$idUsuario/detalles');
    final List data = response.data;
    return data.map((e) => CompletedExamEntity.fromJson(e)).toList();
  }

  /// Obtiene todos los intentos de un examen específico (premium: HISTORIAL)
  Future<ExamMisIntentosEntity> getMisIntentos(int idExamen) async {
    final response =
        await DioClient.dio.get('/examen/$idExamen/mis-intentos');
    return ExamMisIntentosEntity.fromJson(response.data);
  }

  Future<CompletedExamEntity> submitExam({
    required int idExamen,
    required Map<int, int> respuestas,
  }) async {
    final userResp = await DioClient.dio.get('/usuarios/me');
    final idUsuario = userResp.data['id_usuario'];

    final payload = {
      'id_examen': idExamen,
      'id_usuario': idUsuario,
      'respuestas': respuestas.entries
          .map((entry) => {
                'id_pregunta': entry.key,
                'id_opcion': entry.value,
              })
          .toList(),
    };

    final response =
        await DioClient.dio.post('/examen/submit', data: payload);
    return CompletedExamEntity.fromSubmitJson(response.data);
  }
}
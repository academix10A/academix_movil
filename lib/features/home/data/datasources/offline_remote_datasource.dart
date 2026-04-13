import 'package:academix/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class OfflineRemoteDataSource {

  Future<Map<String, dynamic>> obtenerRecursoCompleto(int idRecurso) async {
    final response = await DioClient.dio.get('/recurso/$idRecurso');
    return response.data as Map<String, dynamic>;
  }

  Future<void> registrar(int idRecurso) async {
    try {
      await DioClient.dio.post('/offline/$idRecurso');
    } on DioException catch (e) {
      if (e.response?.statusCode != 409) rethrow;
    }
  }

  Future<void> eliminar(int idRecurso) async {
    try {
      await DioClient.dio.delete('/offline/$idRecurso');
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> obtenerTodos() async {
    final response = await DioClient.dio.get('/offline/');
    final List data = response.data as List;
    return List<Map<String, dynamic>>.from(data);
  }
}
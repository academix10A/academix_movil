import 'package:academix/core/network/dio_client.dart';

class ProgresoRemoteDataSource {

  Future<Map<String, dynamic>?> obtenerProgreso(int idRecurso) async {
    try {
      final response = await DioClient.dio.get(
        '/progreso/usuario/recurso/$idRecurso',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // 404 = no existe progreso aún, no es error crítico
      return null;
    }
  }

  Future<void> actualizarProgreso(
    int idRecurso, {
    required double porcentajeLeido,
    required int ultimaPosicion,
    required bool completado,
  }) async {
    await DioClient.dio.patch(
      '/progreso/recurso/$idRecurso',
      data: {
        'porcentaje_leido': porcentajeLeido,
        'ultima_posicion':  ultimaPosicion,
        'completado':       completado,
      },
    );
  }
}
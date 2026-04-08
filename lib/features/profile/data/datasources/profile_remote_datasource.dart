import '../../../../core/network/dio_client.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/membresia_entity.dart';
import '../models/profile_model.dart';
import '../models/membresia_model.dart';

class ProfileRemoteDataSource {
  Future<UserProfileEntity> getCurrentUser() async {
    final response = await DioClient.dio.get('/usuarios/me');
    return UserProfileModel.fromJson(response.data).toEntity();
  }

  Future<UserProfileEntity> updateProfile({
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
  }) async {
    final userResponse = await DioClient.dio.get('/usuarios/me');
    final userId = userResponse.data['id_usuario'];

    final Map<String, dynamic> data = {};
    if (nombre != null) data['nombre'] = nombre;
    if (apellidoPaterno != null) data['apellido_paterno'] = apellidoPaterno;
    if (apellidoMaterno != null) data['apellido_materno'] = apellidoMaterno;

    final response = await DioClient.dio.put('/usuarios/$userId', data: data);
    return UserProfileModel.fromJson(response.data).toEntity();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userResponse = await DioClient.dio.get('/usuarios/me');
    final userId = userResponse.data['id_usuario'];

    await DioClient.dio.patch(
      '/usuarios/$userId/cambiar-contrasena',
      queryParameters: {
        'contrasena_actual': currentPassword,
        'contrasena_nueva': newPassword,
      },
    );
  }

  Future<List<Membresia>> getMembresias() async {
    final response = await DioClient.dio.get('/membresias/');
    return (response.data as List)
        .map((json) => MembresiaModel.fromJson(json).toEntity())
        .toList();
  }

  Future<UserStatsEntity> getUserStats() async {
    final response = await DioClient.dio.get('/home/usuario/progreso-examenes');
    return UserStatsModel.fromJson(response.data).toEntity();
  }

  Future<int> getNoteCount() async {
    final response = await DioClient.dio.get('/notas/count');
    if (response.statusCode == 200) {
      return response.data['count'];
    }
    return 0;
  }

  Future<int> getResourcesCount() async {
    final response = await DioClient.dio.get('/home/usuario/recursos-leidos');
    if (response.data is List) {
      return (response.data as List).length;
    }
    return 0;
  }

  Future<void> activarMembresia(int idMembresia) async {
    final user = await getCurrentUser();
    await DioClient.dio.post('/usuarios/membresia', data: {
      'id_usuario': user.idUsuario,
      'id_membresia': idMembresia,
    });
  }

  Future<Map<String, dynamic>> createPaypalOrder(int idMembresia) async {
    final response = await DioClient.dio.post('/paypal/create-order', data: {
      'id_membresia': idMembresia,
    });
    return response.data;
  }

  Future<void> capturePaypalOrder(String orderId, int idMembresia) async {
    await DioClient.dio.post('/paypal/capture/$orderId', data: {
      'id_membresia': idMembresia,
    });
  }
}
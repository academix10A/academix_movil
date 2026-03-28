import '../../../../core/network/dio_client.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/membresia_entity.dart';

class ProfileRemoteDataSource {
  Future<UserProfileEntity> getCurrentUser() async {
    final response = await DioClient.dio.get('/usuarios/me');

    return UserProfileEntity.fromJson(response.data);
  }

  Future<UserProfileEntity> updateProfile({
    String? nombre,
    String? fotoPerfil,
  }) async {
    // First get current user to get the user ID
    final userResponse = await DioClient.dio.get('/usuarios/me');
    final userId = userResponse.data['id_usuario'];
    
    final Map<String, dynamic> data = {};
    
    if (nombre != null) data['nombre'] = nombre;
    if (fotoPerfil != null) data['foto_perfil'] = fotoPerfil;

    final response = await DioClient.dio.put('/usuarios/$userId', data: data);

    return UserProfileEntity.fromJson(response.data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // First get current user to get the user ID
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
        .map((json) => Membresia.fromJson(json))
        .toList();
  }

  /// Get user exam progress statistics
  Future<UserStatsEntity> getUserStats() async {
    final response = await DioClient.dio.get('/home/usuario/progreso-examenes');
    return UserStatsEntity.fromJson(response.data);
  }

  Future<int> getNoteCount() async {
    final response = await DioClient.dio.get('/notas/count');

    if (response.statusCode == 200) {
      return response.data['count'];
    }

    return 0;
  }

  /// Get user resources read count
  Future<int> getResourcesCount() async {
    final response = await DioClient.dio.get('/home/usuario/recursos-leidos');
    if (response.data is List) {
      return (response.data as List).length;
    }
    return 0;
  }
}


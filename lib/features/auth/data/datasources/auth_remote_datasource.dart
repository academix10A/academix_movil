import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

// El datasource solo se comunica con la API.
// No guarda tokens, no encadena operaciones de negocio.
// Eso es responsabilidad del repositorio.
class AuthRemoteDataSource {
  // Retorna el token crudo o lanza una excepción.
  // No retorna null — los errores se propagan para que el repositorio decida.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await DioClient.dio.post(
      '/login/access-token',
      data: {
        'username': email,
        'password': password,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final token = response.data['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token no recibido del servidor');
    }
    return token;
  }

  // Retorna el id del usuario creado.
  Future<int> registerUser(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    final response = await DioClient.dio.post(
      '/usuarios/',
      data: model.toJson(),
    );
    final userId = response.data['id_usuario'] as int?;
    if (userId == null) {
      throw Exception('ID de usuario no recibido del servidor');
    }
    return userId;
  }

  // Asigna membresía por separado — responsabilidad única.
  Future<void> assignMembership({
    required int userId,
    required int membershipId,
  }) async {
    await DioClient.dio.post(
      '/usuarios/membresia',
      data: {
        'id_usuario': userId,
        'id_membresia': membershipId,
      },
    );
  }
}
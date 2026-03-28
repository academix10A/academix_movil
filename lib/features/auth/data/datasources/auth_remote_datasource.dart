import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/storage/session_manager.dart';

class AuthRemoteDataSource {
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
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

      if (response.statusCode == 200) {
        final token = response.data['access_token'];

        await SessionManager.saveToken(token);

        return token;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> registerUser(UserEntity user) async {
    try {
      final response = await DioClient.dio.post(
        '/usuarios/',
        data: user.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {

        final userId = response.data['id_usuario'];

        final newData = {
          "id_usuario": userId,
          "id_membresia": 2
        };

        await DioClient.dio.post(
          '/usuarios/membresia',
          data: newData,
        );

        final token = await login(
          email: user.correo,
          password: user.contrasena,
        );

        return token != null;

      } else {
        return false;
      }

    } catch (e) {
      return false;
    }
  }
}

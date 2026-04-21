import '../../../../core/storage/session_manager.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

// El repositorio es el único responsable de:
// 1. Coordinar llamadas al datasource.
// 2. Guardar el token en sesión (un solo lugar).
// 3. Convertir excepciones de infraestructura en resultados del dominio.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  const AuthRepositoryImpl(this.remote);

  @override
  Future<String?> login(String email, String password) async {
    try {
      final token = await remote.login(email: email, password: password);
      await SessionManager.saveToken(token);
      return token;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> registerUser(UserEntity user) async {
    try {
      // 1. Crear usuario
      final userId = await remote.registerUser(user);

      // 2. Asignar membresía (membresía 2 = básica)
      await remote.assignMembership(userId: userId, membershipId: 2);

      // 3. Login automático post-registro
      final token = await remote.login(
        email: user.correo,
        password: user.contrasena,
      );
      await SessionManager.saveToken(token);

      return true;
    } catch (_) {
      return false;
    }
  }
}
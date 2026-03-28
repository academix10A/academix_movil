import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<bool> registerUser(UserEntity user) {
    return remote.registerUser(user);
  }

  @override
  Future<String?> login(String email, String password) {
    return remote.login(email: email, password: password);
  }
}

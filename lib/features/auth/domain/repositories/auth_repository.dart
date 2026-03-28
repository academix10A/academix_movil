import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<String?> login(String email, String password);
  Future<bool> registerUser(UserEntity user);
}

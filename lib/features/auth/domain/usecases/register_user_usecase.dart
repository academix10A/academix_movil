import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  const RegisterUserUseCase(this.repository);

  Future<bool> call(UserEntity user) {
    return repository.registerUser(user);
  }
}
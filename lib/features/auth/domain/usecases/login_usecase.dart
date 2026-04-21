import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<String?> call(String email, String password) {
    return repository.login(email, password);
  }
}
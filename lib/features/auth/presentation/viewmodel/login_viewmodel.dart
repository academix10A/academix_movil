import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../../../core/storage/session_manager.dart';

class LoginViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  late final LoginUseCase _loginUseCase;

  String errorMessage = '';

  LoginViewModel() {
    // Inyección manual de dependencias
    final AuthRemoteDataSource remote = AuthRemoteDataSource();
    final AuthRepository repository = AuthRepositoryImpl(remote);
    _loginUseCase = LoginUseCase(repository);
  }

  Future<bool> login() async {
    if (emailController.text.isEmpty ||
        passController.text.isEmpty) {
      errorMessage = 'Todos los campos son obligatorios';
      notifyListeners();
      return false;
    }

    final token = await _loginUseCase(
      emailController.text,
      passController.text,
    );

    if (token != null && token.isNotEmpty) {
      // Guardar el token en SessionManager
      await SessionManager.saveToken(token);
      print('Token guardado: $token');
      return true;
    } else {
      errorMessage = 'Credenciales inválidas';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';

// El ViewModel solo conoce el UseCase — no sabe nada de repositorios ni datasources.
// Las dependencias se inyectan desde afuera (constructor injection).
class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  LoginViewModel({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase;

  final emailController = TextEditingController();
  final passController = TextEditingController();

  String errorMessage = '';
  bool isLoading = false;

  Future<bool> login() async {
    if (emailController.text.trim().isEmpty ||
        passController.text.trim().isEmpty) {
      errorMessage = 'Todos los campos son obligatorios';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    final token = await _loginUseCase(
      emailController.text.trim(),
      passController.text,
    );

    isLoading = false;

    if (token != null && token.isNotEmpty) {
      notifyListeners();
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
import 'package:flutter/material.dart';

// Interfaz para el repositorio de recuperación de contraseña.
// Permite que el ViewModel no dependa de la implementación concreta.
// Cuando implementes el endpoint real, crea ForgotPasswordRepositoryImpl
// y pásalo al constructor sin tocar el ViewModel ni la View.
abstract class ForgotPasswordRepository {
  Future<bool> sendResetEmail(String email);
}

// Implementación temporal (mock) que cumple el contrato.
// Reemplazar por la implementación real cuando el backend esté listo.
class ForgotPasswordRepositoryMock implements ForgotPasswordRepository {
  @override
  Future<bool> sendResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

class ForgotPasswordViewModel extends ChangeNotifier {
  final ForgotPasswordRepository _repository;

  ForgotPasswordViewModel({ForgotPasswordRepository? repository})
      : _repository = repository ?? ForgotPasswordRepositoryMock();

  final emailController = TextEditingController();

  String? errorMessage;
  String? successMessage;
  bool isLoading = false;

  Future<bool> sendResetEmail() async {
    errorMessage = null;
    successMessage = null;

    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      errorMessage = 'Email válido requerido';
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    final success = await _repository.sendResetEmail(email);

    isLoading = false;

    if (success) {
      successMessage = 'Email de recuperación enviado. Revisa tu bandeja.';
    } else {
      errorMessage = 'No se pudo enviar el email. Intenta más tarde.';
    }

    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
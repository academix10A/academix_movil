import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';

class RegisterViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> register() async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    // Mock validation
    if (nameController.text.isEmpty) {
      errorMessage = 'El nombre es requerido';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      errorMessage = 'Email válido requerido';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (passwordController.text.length < 8) {
      errorMessage = 'Contraseña mínimo 8 caracteres';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      errorMessage = 'Las contraseñas no coinciden';
      isLoading = false;
      notifyListeners();
      return false;
    }

    // Mock API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock success
    isLoading = false;
    notifyListeners();
    return true;
  }
}

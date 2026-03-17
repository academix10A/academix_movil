import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();

  String? errorMessage;
  String? successMessage;
  bool isLoading = false;
  bool isSent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<bool> sendResetEmail() async {
    errorMessage = null;
    successMessage = null;
    isLoading = true;
    notifyListeners();

    // Mock validation
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      errorMessage = 'Email válido requerido';
      isLoading = false;
      notifyListeners();
      return false;
    }

    // Mock API
    await Future.delayed(const Duration(seconds: 1));
    isSent = true;
    successMessage = 'Email de recuperación enviado. Revisa tu bandeja.';
    isLoading = false;
    notifyListeners();
    return true;
  }
}


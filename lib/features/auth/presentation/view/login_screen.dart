import 'package:flutter/material.dart';
import "package:academix/core/constants/app_spacing.dart";
import "package:academix/core/themes/app_text_styles.dart";
import "package:academix/core/themes/app_colors.dart";
import "package:academix/features/auth/presentation/viewmodel/login_viewmodel.dart";
import "package:academix/core/routes/app_routes.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginViewModel vm = LoginViewModel();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
                - MediaQuery.of(context).padding.top
                - MediaQuery.of(context).padding.bottom
                - 48, // el padding de 24 * 2
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    "assets/images/logo.png",
                    height: 128,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    "Tu biblioteca virtual colaborativa",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Correo electrónico",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: vm.emailController,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          hintText: "tucorreo@ejemplo.com",
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Password
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contraseña",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: vm.passController,
                        obscureText: true,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          hintText: "Mínimo 8 caracteres",
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => AppNavigator.push(context, AppRoutes.forgotPassword),
                      child: Text(
                        "¿Olvidaste tu contraseña?",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Login Button
                  ElevatedButton(
                    onPressed: () async {
                      final success = await vm.login();

                      if (success && context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.main,
                          (route) => false,
                        );
                      } else {
                        setState(() {}); // refresca errorMessage
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Iniciar Sesión",
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿No tienes cuenta? ",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      TextButton(
                        onPressed: () => AppNavigator.push(context, AppRoutes.register),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Regístrate",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (vm.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        vm.errorMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


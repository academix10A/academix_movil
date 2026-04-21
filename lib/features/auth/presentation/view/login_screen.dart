import 'package:flutter/material.dart';
import "package:academix/core/constants/app_spacing.dart";
import "package:academix/core/themes/app_text_styles.dart";
import "package:academix/core/themes/app_colors.dart";
import "package:academix/features/auth/presentation/viewmodel/login_viewmodel.dart";
import "package:academix/core/routes/app_routes.dart";
import "package:academix/features/auth/data/datasources/auth_remote_datasource.dart";
import "package:academix/features/auth/data/repositories/auth_repository_impl.dart";
import "package:academix/features/auth/domain/usecases/login_usecase.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel vm;

  @override
  void initState() {
    super.initState();
    // Wiring de dependencias — si usas get_it, esto se reemplaza por
    // vm = LoginViewModel(loginUseCase: getIt<LoginUseCase>())
    final remote = AuthRemoteDataSource();
    final repository = AuthRepositoryImpl(remote);
    vm = LoginViewModel(loginUseCase: LoginUseCase(repository));
  }

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
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
                - MediaQuery.of(context).padding.top
                - MediaQuery.of(context).padding.bottom
                - 48,
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
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final success = await vm.login();
                            if (success && context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.main,
                                (route) => false,
                              );
                            } else {
                              setState(() {});
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
                    child: vm.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
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
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/auth/presentation/viewmodel/forgot_password_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordViewModel vm = ForgotPasswordViewModel();

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
                    "Recupera tu cuenta",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(color: AppColors.text),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    "Ingresa tu email para recibir instrucciones",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Email field
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
                  const SizedBox(height: AppSpacing.xl),

                  // Button
                  ElevatedButton(
                    onPressed: vm.isLoading
                      ? null
                      : () async {
                          await vm.sendResetEmail();
                          setState(() {});
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
                          "Enviar Email",
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (vm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        vm.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (vm.successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        vm.successMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // Back to login
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Volver al login",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
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


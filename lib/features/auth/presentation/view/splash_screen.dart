import 'dart:async';
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/core/storage/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnAuth();
  }

  Future<void> _navigateBasedOnAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final isLoggedIn = await SessionManager.isLoggedIn();
    if (mounted) {
      if (isLoggedIn) {
        AppNavigator.pushReplacementUnique(context, AppRoutes.main);
      } else {
        AppNavigator.pushReplacementUnique(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container animado
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1, milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.accent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Título
            Text(
              'ACADEMIX',
              style: AppTextStyles.display.copyWith(
                fontSize: 42,
                letterSpacing: 3,
                color: AppColors.primary,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              'Tu biblioteca educativa',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.textMuted,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Spinner
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}


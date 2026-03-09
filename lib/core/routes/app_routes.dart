import 'package:flutter/material.dart';

// ─── Route Names ─────────────────────────────────────────────────────────────

abstract class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String main = '/main';
  static const String library = '/library';
  static const String notes = '/notes';
  static const String exams = '/exams';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String premium = '/premium';
  
  // Detail screens
  static const String bookDetail = '/book-detail';
  static const String noteDetail = '/note-detail';
  static const String examTake = '/exam-take';
  static const String examResult = '/exam-result';
}

// ─── Navigation Helper ─────────────────────────────────────────────────────

class AppNavigator {
  /// Navega a una ruta reemplazando la actual (sin historial)
  static Future<void> pushReplacement(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Navega a una ruta (con historial)
  static Future<void> push(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Regresa a la ruta anterior
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Reemplaza todas las rutas hasta el inicio (útil para logout)
  static void popUntilFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Reemplaza la ruta actual con una nueva (sin botón atrás)
  static Future<void> pushReplacementUnique(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}


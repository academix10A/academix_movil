import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:academix/core/utils/env.dart';
import 'package:academix/core/storage/session_manager.dart';
import 'package:academix/core/routes/app_routes.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': Env.apiKey,
      },
    ),
  );

  // Clave global para acceder al navigator sin BuildContext
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void init() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await SessionManager.clearSession();
            _redirectToLogin();
          }
          return handler.next(error);
        },
      ),
    );
  }

  static void _redirectToLogin() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      AppNavigator.pushReplacementUnique(context, AppRoutes.login);
    }
  }
}
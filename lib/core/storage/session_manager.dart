import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static const _tokenKey = 'access_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    return !_isTokenExpired(token);
  }

  /// Verifica si el token ya expiró decodificando el payload JWT
  static bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'] as int?;
      if (exp == null) return true;

      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expDate);
    } catch (_) {
      return true; // Si no se puede leer, tratar como expirado
    }
  }

  /// Expone la verificación para usarla desde el interceptor
  static Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true;
    return _isTokenExpired(token);
  }
}
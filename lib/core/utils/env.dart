import 'package:flutter_dotenv/flutter_dotenv.dart';

// class Env {
//   static String get apiUrl => dotenv.get('API_BASE_URL');
//   static String get apiKey => dotenv.get('API_KEY');
// }

class Env {
  static String get apiUrl {
    final value = dotenv.env['API_BASE_URL'];
    if (value == null) {
      throw Exception('API_BASE_URL no está definida en .env');
    }
    return value;
  }

  static String get apiKey {
    final value = dotenv.env['API_KEY'];
    if (value == null) {
      throw Exception('API_KEY no está definida en .env');
    }
    return value;
  }
}


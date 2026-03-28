import 'package:academix/core/network/dio_client.dart';

class SearchRemoteDataSource {
  static Future<Map<String, dynamic>> search({
    required String query,
    String tipo = 'all',
  }) async {
    try {
      final response = await DioClient.dio.get(
        '/search/',
        queryParameters: {
          'busqueda': query,
          'tipo': tipo,
        },
      );
      print(response.data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getSearchResults({
    required String query,
    String tipo = 'all',
  }) async {
    print("Holaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
    final data = await search(query: query, tipo: tipo);
    return List<Map<String, dynamic>>.from(data['resultados'] ?? []);
  }
}

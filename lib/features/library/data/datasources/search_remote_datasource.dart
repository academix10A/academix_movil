import 'package:academix/core/network/dio_client.dart';

class SearchRemoteDataSource {
  Future<Map<String, dynamic>> search({
    required String query,
    String tipo = 'all',
  }) async {
    final response = await DioClient.dio.get(
      '/search/',
      queryParameters: {
        'busqueda': query,
        'tipo': tipo,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getSearchResults({
    required String query,
    String tipo = 'all',
  }) async {
    final data = await search(query: query, tipo: tipo);
    return List<Map<String, dynamic>>.from(
        (data['resultados'] as List?) ?? []);
  }
}
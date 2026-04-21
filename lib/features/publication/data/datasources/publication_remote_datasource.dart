import 'package:academix/core/network/dio_client.dart';
import '../models/publication_model.dart';

class PublicationRemoteDataSource {
  Future<List<PublicationModel>> getMyPublications() async {
    try {
      final response = await DioClient.dio.get('/publicacion/usuario');
      final List<dynamic> data = response.data;
      return data.map((json) => PublicationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load my publications: $e');
    }
  }

  Future<PublicationModel> createPublication(Map<String, dynamic> data) async {
    try {
      // Ruta correcta: POST /publicacion/
      final response = await DioClient.dio.post('/publicacion/', data: data);
      return PublicationModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create publication: $e');
    }
  }

  Future<PublicationModel> updatePublication(int id, Map<String, dynamic> data) async {
    try {
      // Ruta correcta: PUT /publicacion/{id}
      final response = await DioClient.dio.put('/publicacion/$id', data: data);
      return PublicationModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update publication: $e');
    }
  }

  Future<void> deletePublication(int id) async {
    try {
      // Ruta correcta: DELETE /publicacion/{id}
      await DioClient.dio.delete('/publicacion/$id');
    } catch (e) {
      throw Exception('Failed to delete publication: $e');
    }
  }
}
import 'package:academix/core/network/dio_client.dart';
import '../models/publication_model.dart';

class PublicationRemoteDataSource {
  Future<PublicationModel> getPublicationById(int id) async {
    try {
      final response = await DioClient.dio.get('/publicacion/$id');
      return PublicationModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load publication: $e');
    }
  }
}




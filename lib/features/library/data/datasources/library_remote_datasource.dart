import '../../../../core/network/dio_client.dart';
import '../../domain/entities/library_entity.dart';

class LibraryRemoteDataSource {
  Future<List<LibraryResourceEntity>> getResources() async {
    final response = await DioClient.dio.get('/recurso/');

    final List data = response.data;

    return data.map((e) => LibraryResourceEntity.fromJson(e)).toList();
  }

  Future<LibraryResourceEntity> getResourceById(int id) async {
    final response = await DioClient.dio.get('/recurso/$id');

    return LibraryResourceEntity.fromJson(response.data);
  }

  Future<List<LibraryResourceEntity>> searchResources(String query) async {
    final response = await DioClient.dio.get('/recurso/');

    final List data = response.data;

    final resources = data.map((e) => LibraryResourceEntity.fromJson(e)).toList();

    if (query.isEmpty) {
      return resources;
    }

    final lowerQuery = query.toLowerCase();
    return resources.where((r) {
      return r.titulo.toLowerCase().contains(lowerQuery) ||
          (r.descripcion?.toLowerCase().contains(lowerQuery) ?? false) ||
          (r.contenido?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}


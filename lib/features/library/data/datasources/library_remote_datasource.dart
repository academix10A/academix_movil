import '../../../../core/network/dio_client.dart';
import '../../domain/entities/library_entity.dart';
import 'package:academix/features/library/domain/entities/tema_entity.dart';

class LibraryRemoteDataSource {
  Future<List<LibraryResourceEntity>> getResources() async {
    final response = await DioClient.dio.get('/recurso/');
    final List data = response.data;
    return data.map((e) => LibraryResourceEntity.fromJson(e)).toList();
  }

  Future<LibraryResourceEntity> getRecursoById(int id) async {
    final response = await DioClient.dio.get('/recurso/$id');
    return LibraryResourceEntity.fromJson(response.data);
  }

  Future<LibraryResourceEntity> postFavorite(
      int idUsuario, int idRecurso) async {
    final response =
        await DioClient.dio.post('/recurso/$idUsuario/$idRecurso');
    return LibraryResourceEntity.fromJson(response.data);
  }

  Future<LibraryResourceEntity> deleteFavorite(
      int idUsuario, int idRecurso) async {
    final response =
        await DioClient.dio.delete('/recurso/$idUsuario/$idRecurso');
    return LibraryResourceEntity.fromJson(response.data);
  }

  Future<List<TemaResourceEntity>> getResourcesFromTemas() async {
    final response = await DioClient.dio.get('/recurso/temas-con-recursos');
    final List data = response.data;

    List<TemaResourceEntity> resources = [];

    for (var tema in data) {
      final String temaNombre = tema['nombre'];

      for (var subtema in tema['subtemas']) {
        final String subtemaNombre = subtema['nombre'];

        for (var recurso in subtema['recursos']) {
          resources.add(
            TemaResourceEntity(
              id: recurso['id_recurso'],
              titulo: recurso['titulo'],
              descripcion: recurso['descripcion'] ?? '',
              tema: temaNombre,
              subtema: subtemaNombre,
              urlArchivo: recurso['url_archivo'],   // nuevo
              idTipo: recurso['id_tipo'],            // nuevo
            ),
          );
        }
      }
    }

    return resources;
  }

  Future<LibraryResourceEntity> getResourceById(int id) async {
    final response = await DioClient.dio.get('/recurso/$id');
    return LibraryResourceEntity.fromJson(response.data);
  }

  Future<List<LibraryResourceEntity>> searchResources(String query) async {
    final response = await DioClient.dio.get('/recurso/');
    final List data = response.data;

    final resources =
        data.map((e) => LibraryResourceEntity.fromJson(e)).toList();

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

  Future<List<LibraryResourceEntity>> getFavorites(int idUsuario) async {
    final response =
        await DioClient.dio.get('/recurso/favoritos/$idUsuario');
    final List data = response.data;
    return data.map((e) => LibraryResourceEntity.fromJson(e)).toList();
  }
}
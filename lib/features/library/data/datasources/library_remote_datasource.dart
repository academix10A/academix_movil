import 'package:academix/core/network/dio_client.dart';
import '../models/library_resource_model.dart';
import '../models/tema_resource_model.dart';

class LibraryRemoteDataSource {
  Future<List<LibraryResourceModel>> getResources() async {
    final response = await DioClient.dio.get('/recurso/');
    final List data = response.data as List;
    return data
        .map((e) => LibraryResourceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LibraryResourceModel> getRecursoById(int id) async {
    final response = await DioClient.dio.get('/recurso/$id');
    return LibraryResourceModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> postFavorite(int idUsuario, int idRecurso) async {
    await DioClient.dio.post('/recurso/$idUsuario/$idRecurso');
  }

  Future<void> deleteFavorite(int idUsuario, int idRecurso) async {
    await DioClient.dio.delete('/recurso/$idUsuario/$idRecurso');
  }

  Future<List<TemaResourceModel>> getResourcesFromTemas() async {
    final response =
        await DioClient.dio.get('/recurso/temas-con-recursos');
    return TemaResourceModel.fromTemasJson(response.data as List);
  }

  Future<List<LibraryResourceModel>> searchResources(String query) async {
    final response = await DioClient.dio.get('/recurso/');
    final List data = response.data as List;

    final resources = data
        .map((e) => LibraryResourceModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (query.isEmpty) return resources;

    final lowerQuery = query.toLowerCase();
    return resources.where((r) {
      return r.titulo.toLowerCase().contains(lowerQuery) ||
          (r.descripcion?.toLowerCase().contains(lowerQuery) ?? false) ||
          (r.contenido?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<List<LibraryResourceModel>> getFavorites(int idUsuario) async {
    final response =
        await DioClient.dio.get('/recurso/favoritos/$idUsuario');
    final List data = response.data as List;
    return data
        .map((e) => LibraryResourceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
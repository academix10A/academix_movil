import '../../../../core/network/dio_client.dart';
import '../../domain/entities/home_entity.dart';

class HomeRemoteDataSource {

  Future<String> getUserName() async {
    final response = await DioClient.dio.get('/usuarios/me');
    
    return '${response.data['nombre']}';
  }

  Future<Map<String, dynamic>> getExamProgress() async {
    final response = await DioClient.dio.get('/home/usuario/progreso-examenes');

    return response.data;
  }

  Future<List<RecentItemEntity>> getRecentItems() async {
    final response = await DioClient.dio.get('/home/usuario/recientes');

    final List data = response.data;

    return data.map((e) =>
      RecentItemEntity(
        id: e['id'] ?? '',
        title: e['titulo'] ?? '',
        subtitle: e['descripcion'] ?? '',
        category: e['tipo'] ?? '',
      )
    ).toList();
  }
  
  Future<List<Map<String, dynamic>>> getReadResources() async {
    final response = await DioClient.dio.get('/home/usuario/recursos-leidos');

    final List data = response.data;

    return List<Map<String, dynamic>>.from(data);
  }
}

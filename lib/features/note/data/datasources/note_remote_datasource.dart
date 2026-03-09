import '../../../../core/network/dio_client.dart';
import '../../domain/entities/note_entity.dart';

class NoteRemoteDataSource {
  Future<List<NoteEntity>> getNotes() async {
    final response = await DioClient.dio.get('/notas/usuario');

    final List data = response.data;

    return data.map((e) => NoteEntity.fromJson(e)).toList();
  }

  Future<NoteEntity> getNoteById(int id) async {
    final response = await DioClient.dio.get('/notas/$id');

    return NoteEntity.fromJson(response.data);
  }

  Future<NoteEntity> createNote({
    required String contenido,
    int? idRecurso,
    bool esCompartida = false,
  }) async {
    final response = await DioClient.dio.post('/notas/', data: {
      'contenido': contenido,
      'id_recurso': idRecurso,
      'es_compartida': esCompartida,
    });

    return NoteEntity.fromJson(response.data);
  }

  Future<NoteEntity> updateNote({
    required int id,
    required String contenido,
    bool esCompartida = false,
  }) async {
    final response = await DioClient.dio.put('/notas/$id', data: {
      'contenido': contenido,
      'es_compartida': esCompartida,
    });

    return NoteEntity.fromJson(response.data);
  }

  Future<void> deleteNote(int id) async {
    await DioClient.dio.delete('/notas/$id');
  }
}


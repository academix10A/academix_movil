import '../../../../core/network/dio_client.dart';
import '../../domain/entities/note_entity.dart';
import '../models/note_model.dart';

class NoteRemoteDataSource {
  Future<List<NoteEntity>> getNotes() async {
    final response = await DioClient.dio.get('/notas/usuario');
    final List data = response.data;
    return data.map((e) => NoteModel.fromJson(e).toEntity()).toList();
  }

  Future<NoteEntity> getNoteById(int id) async {
    final response = await DioClient.dio.get('/notas/$id');
    return NoteModel.fromJson(response.data).toEntity();
  }

  Future<NoteEntity> createNote({
    required String titulo,
    required String contenido,
    int? idRecurso,
    bool esCompartida = false,
  }) async {
    final response = await DioClient.dio.post('/notas/', data: {
      'titulo': titulo,
      'contenido': contenido,
      'id_recurso': idRecurso,
      'es_compartida': esCompartida,
    });
    return NoteModel.fromJson(response.data).toEntity();
  }

  Future<NoteEntity> updateNote({
    required int id,
    required String titulo,
    required String contenido,
    bool esCompartida = false,
  }) async {
    final response = await DioClient.dio.put('/notas/$id', data: {
      'titulo': titulo,
      'contenido': contenido,
      'es_compartida': esCompartida,
    });
    return NoteModel.fromJson(response.data).toEntity();
  }

  Future<void> deleteNote(int id) async {
    await DioClient.dio.delete('/notas/$id');
  }

  Future<List<NoteEntity>> getSharedNotesByResource(int idRecurso) async {
    final response =
        await DioClient.dio.get('/notas/recurso/$idRecurso/compartidas');
    final List data = response.data['notas'] as List;
    return data.map((e) => NoteModel.fromJson(e).toEntity()).toList();
  }
}
import '../../domain/repositories/note_repository.dart';
import '../../domain/entities/note_entity.dart';
import '../datasources/note_remote_datasource.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remote;

  NoteRepositoryImpl(this.remote);

  @override
  Future<List<NoteEntity>> getNotes() {
    return remote.getNotes();
  }

  @override
  Future<NoteEntity> getNoteById(int id) {
    return remote.getNoteById(id);
  }

  @override
  Future<NoteEntity> createNote(String contenido, int? idRecurso, bool esCompartida) {
    return remote.createNote(
      contenido: contenido,
      idRecurso: idRecurso,
      esCompartida: esCompartida,
    );
  }

  @override
  Future<NoteEntity> updateNote(int id, String contenido, bool esCompartida) {
    return remote.updateNote(
      id: id,
      contenido: contenido,
      esCompartida: esCompartida,
    );
  }

  @override
  Future<void> deleteNote(int id) {
    return remote.deleteNote(id);
  }
}


import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_remote_datasource.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource _remote;

  const NoteRepositoryImpl(this._remote);

  @override
  Future<List<NoteEntity>> getNotes() => _remote.getNotes();

  @override
  Future<NoteEntity> getNoteById(int id) => _remote.getNoteById(id);

  @override
  Future<NoteEntity> createNote({
    required String titulo,
    required String contenido,
    int? idRecurso,
    bool esCompartida = false,
  }) =>
      _remote.createNote(
        titulo: titulo,
        contenido: contenido,
        idRecurso: idRecurso,
        esCompartida: esCompartida,
      );

  @override
  Future<NoteEntity> updateNote({
    required int id,
    required String titulo,
    required String contenido,
    bool esCompartida = false,
  }) =>
      _remote.updateNote(
        id: id,
        titulo: titulo,
        contenido: contenido,
        esCompartida: esCompartida,
      );

  @override
  Future<void> deleteNote(int id) => _remote.deleteNote(id);

  @override
  Future<List<NoteEntity>> getSharedNotesByResource(int idRecurso) =>
      _remote.getSharedNotesByResource(idRecurso);
}
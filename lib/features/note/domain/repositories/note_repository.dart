import '../entities/note_entity.dart';

abstract class NoteRepository {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity> getNoteById(int id);
  Future<NoteEntity> createNote({
    required String titulo,
    required String contenido,
    int? idRecurso,
    bool esCompartida,
  });
  Future<NoteEntity> updateNote({
    required int id,
    required String titulo,
    required String contenido,
    bool esCompartida,
  });
  Future<void> deleteNote(int id);
  Future<List<NoteEntity>> getSharedNotesByResource(int idRecurso);
}
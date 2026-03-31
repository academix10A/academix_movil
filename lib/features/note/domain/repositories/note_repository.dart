import '../entities/note_entity.dart';

abstract class NoteRepository {
  Future<List<NoteEntity>> getNotes();
  Future<NoteEntity> getNoteById(int id);
  Future<NoteEntity> createNote(String titulo, String contenido, int? idRecurso, bool esCompartida);
  Future<NoteEntity> updateNote(int id, String titulo, String contenido, bool esCompartida);
  Future<void> deleteNote(int id);
}


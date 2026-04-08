import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class GetNotesUseCase {
  final NoteRepository _repository;
  const GetNotesUseCase(this._repository);

  Future<List<NoteEntity>> call() => _repository.getNotes();
}

class GetNoteByIdUseCase {
  final NoteRepository _repository;
  const GetNoteByIdUseCase(this._repository);

  Future<NoteEntity> call(int id) => _repository.getNoteById(id);
}

class CreateNoteUseCase {
  final NoteRepository _repository;
  const CreateNoteUseCase(this._repository);

  Future<NoteEntity> call({
    required String titulo,
    required String contenido,
    int? idRecurso,
    bool esCompartida = false,
  }) {
    if (titulo.trim().isEmpty) throw ArgumentError('El título es requerido');
    if (contenido.trim().isEmpty) throw ArgumentError('El contenido es requerido');

    return _repository.createNote(
      titulo: titulo.trim(),
      contenido: contenido.trim(),
      idRecurso: idRecurso,
      esCompartida: esCompartida,
    );
  }
}

class UpdateNoteUseCase {
  final NoteRepository _repository;
  const UpdateNoteUseCase(this._repository);

  Future<NoteEntity> call({
    required int id,
    required String titulo,
    required String contenido,
    bool esCompartida = false,
  }) {
    if (titulo.trim().isEmpty) throw ArgumentError('El título es requerido');
    if (contenido.trim().isEmpty) throw ArgumentError('El contenido es requerido');

    return _repository.updateNote(
      id: id,
      titulo: titulo.trim(),
      contenido: contenido.trim(),
      esCompartida: esCompartida,
    );
  }
}

class DeleteNoteUseCase {
  final NoteRepository _repository;
  const DeleteNoteUseCase(this._repository);

  Future<void> call(int id) => _repository.deleteNote(id);
}

class GetSharedNotesByResourceUseCase {
  final NoteRepository _repository;
  const GetSharedNotesByResourceUseCase(this._repository);

  Future<List<NoteEntity>> call(int idRecurso) =>
      _repository.getSharedNotesByResource(idRecurso);
}
// note/domain/usecases/get_note_by_id_usecase.dart
import '../../../note/domain/entities/note_entity.dart';
import '../../../note/domain/repositories/note_repository.dart';

class GetNoteByIdUseCase {
  final NoteRepository repository;

  const GetNoteByIdUseCase(this.repository);

  Future<NoteEntity> call(int id) => repository.getNoteById(id);
}
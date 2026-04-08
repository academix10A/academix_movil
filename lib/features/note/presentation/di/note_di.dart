import '../../data/datasources/note_remote_datasource.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/note_usecases.dart';
import '../viewmodel/notes_viewmodel.dart';
import '../viewmodel/create_note_viewmodel.dart';

/// Punto central de inyección de dependencias del módulo Note.
/// Los ViewModels NUNCA instancian repositorios ni datasources directamente.
class NoteDI {
  NoteDI._();

  // ── Datasources ────────────────────────────────────────────────────────────
  static NoteRemoteDataSource get remoteDataSource => NoteRemoteDataSource();

  // ── Repositories ───────────────────────────────────────────────────────────
  static NoteRepository get repository =>
      NoteRepositoryImpl(remoteDataSource);

  // ── Use Cases ──────────────────────────────────────────────────────────────
  static GetNotesUseCase get getNotesUseCase =>
      GetNotesUseCase(repository);

  static CreateNoteUseCase get createNoteUseCase =>
      CreateNoteUseCase(repository);

  static UpdateNoteUseCase get updateNoteUseCase =>
      UpdateNoteUseCase(repository);

  static DeleteNoteUseCase get deleteNoteUseCase =>
      DeleteNoteUseCase(repository);

  static GetSharedNotesByResourceUseCase get getSharedNotesByResourceUseCase =>
      GetSharedNotesByResourceUseCase(repository);

  // ── ViewModels ─────────────────────────────────────────────────────────────
  static NotesViewModel notesViewModel() => NotesViewModel(
        getNotesUseCase: getNotesUseCase,
        createNoteUseCase: createNoteUseCase,
        updateNoteUseCase: updateNoteUseCase,
        deleteNoteUseCase: deleteNoteUseCase,
      );

  static CreateNoteViewModel createNoteViewModel() => CreateNoteViewModel(
        createNoteUseCase: createNoteUseCase,
      );
}
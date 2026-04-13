// note/presentation/viewmodel/note_detail_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:academix/features/note/domain/entities/note_entity.dart';
import 'package:academix/features/library/domain/usecases/get_note_by_id_usecase.dart';

class NoteDetailViewModel {
  final GetNoteByIdUseCase getNoteByIdUseCase;

  NoteDetailViewModel({required this.getNoteByIdUseCase});

  final ValueNotifier<NoteEntity?> note = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  Future<void> loadNote(int id) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await getNoteByIdUseCase(id);
      note.value = result;
    } catch (e) {
      errorMessage.value = 'Error al cargar la nota: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    note.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
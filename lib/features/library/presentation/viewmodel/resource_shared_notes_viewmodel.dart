import 'package:flutter/material.dart';
import 'package:academix/features/note/data/datasources/note_remote_datasource.dart';
import 'package:academix/features/note/domain/entities/note_entity.dart';
class ResourceSharedNotesViewModel {
  final NoteRemoteDataSource _remoteDataSource = NoteRemoteDataSource();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<List<NoteEntity>> notes = ValueNotifier<List<NoteEntity>>([]);
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
  late ValueNotifier<List<NoteEntity>> filteredNotes;

  ResourceSharedNotesViewModel() {
    filteredNotes = ValueNotifier(notes.value);
    searchQuery.addListener(_applySearchFilter);
    notes.addListener(_applySearchFilter);
  }

  Future<void> loadSharedNotes(int idRecurso) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final loadedNotes = await _remoteDataSource.getSharedNotesByResource(idRecurso);
      notes.value = loadedNotes;
    } catch (e) {
      errorMessage.value = 'Error al cargar notas compartidas: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _applySearchFilter() {
    final query = searchQuery.value.toLowerCase();
    filteredNotes.value = notes.value.where((note) {
      return note.titulo.toLowerCase().contains(query) ||
             note.contenido.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    notes.dispose();
    searchQuery.dispose();
    filteredNotes.dispose();
  }
}

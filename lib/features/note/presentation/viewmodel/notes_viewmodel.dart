import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/note/domain/entities/note_entity.dart';
import 'package:academix/features/library/domain/entities/library_entity.dart';
import 'package:academix/features/note/data/datasources/note_remote_datasource.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';

enum NoteFilter {
  todos,
  privadas,
  compartidas;

  String get label {
    switch (this) {
      case NoteFilter.todos:
        return 'Todos';
      case NoteFilter.privadas:
        return 'Privadas';
      case NoteFilter.compartidas:
        return 'Compartidas';
    }
  }
}

class NoteItem {
  final String id;
  final String title;
  final String content;
  final String preview;
  final String timeAgo;
  final List<String> tags;
  final bool isShared;
  final LibraryResource? resource;

  const NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.preview,
    required this.timeAgo,
    required this.tags,
    this.isShared = false,
    this.resource,
  });

  bool get hasResource => resource != null;

  // Mapper desde entity
  factory NoteItem.fromEntity(NoteEntity entity) {
    return NoteItem(
      id: entity.idNota.toString(),
      title: entity.title,
      content: entity.contenido,
      preview: entity.preview,
      timeAgo: entity.timeAgo,
      tags: entity.tags,
      isShared: entity.isShared,
      resource: entity.recurso != null
        ? LibraryResource.fromEntity(entity.recurso!)
        : null,
    );
  }
}

class NotesViewModel {
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<NoteFilter> selectedFilter =
      ValueNotifier<NoteFilter>(NoteFilter.todos);
  final ValueNotifier<List<NoteItem>> filteredNotes =
      ValueNotifier<List<NoteItem>>([]);

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  final NoteRemoteDataSource _remoteDataSource = NoteRemoteDataSource();
  List<NoteItem> _allNotes = [];

  NotesViewModel() {
    searchController.addListener(_applyFilters);
    selectedFilter.addListener(_applyFilters);
    loadNotes();
  }

  Future<void> loadNotes() async {
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      final entities = await _remoteDataSource.getNotes();
      _allNotes = entities.map((e) => NoteItem.fromEntity(e)).toList();
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Error al cargar notas: $e';
      _allNotes = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createNote(String contenido, {int? idRecurso, bool esCompartida = false}) async {
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      await _remoteDataSource.createNote(
        contenido: contenido,
        idRecurso: idRecurso,
        esCompartida: esCompartida,
      );
      await loadNotes();
    } catch (e) {
      errorMessage.value = 'Error al crear nota: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteNote(int id) async {
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      await _remoteDataSource.deleteNote(id);
      await loadNotes();
    } catch (e) {
      errorMessage.value = 'Error al eliminar nota: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase();
    final filter = selectedFilter.value;

    filteredNotes.value = _allNotes.where((note) {
      final matchesFilter = switch (filter) {
        NoteFilter.todos => true,
        NoteFilter.privadas => !note.isShared,
        NoteFilter.compartidas => note.isShared,
      };

      final matchesQuery = query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.preview.toLowerCase().contains(query) ||
          note.tags.any((t) => t.toLowerCase().contains(query));

      return matchesFilter && matchesQuery;
    }).toList();
  }

  void selectFilter(NoteFilter filter) {
    selectedFilter.value = filter;
  }

  void onSearch(String query) {
    _applyFilters();
  }

  void onNoteTap(BuildContext context, NoteItem note) {
    AppNavigator.push(
      context,
      AppRoutes.noteDetail,
      arguments: note,
    );
  }

  void onCreateNote() {
    // TODO: Navegar a crear nueva nota
    debugPrint('Create new note');
  }

  void dispose() {
    searchController.dispose();
    selectedFilter.dispose();
    filteredNotes.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}


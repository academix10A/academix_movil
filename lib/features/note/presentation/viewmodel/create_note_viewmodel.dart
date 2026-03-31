import 'package:flutter/material.dart';
import 'package:academix/features/note/presentation/viewmodel/notes_viewmodel.dart';

class CreateNoteViewModel extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ValueNotifier<List<String>> tags = ValueNotifier<List<String>>([]);
  bool isPublic = false;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  int? selectedResourceId;
  final ValueNotifier<String?> selectedResourceTitle = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasResource = ValueNotifier<bool>(false);

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    tags.dispose();
    selectedResourceTitle.dispose();
    hasResource.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    super.dispose();
  }

  void togglePublic() {
    isPublic = !isPublic;
    notifyListeners();
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !tags.value.contains(tag)) {
      tags.value = [...tags.value, tag.toLowerCase()];
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    tags.value = tags.value.where((t) => t != tag).toList();
    notifyListeners();
  }

  void setSelectedResource(int? id, String? title) {
    selectedResourceId = id;
    selectedResourceTitle.value = title;
    hasResource.value = id != null;
    notifyListeners();
  }

  Future<bool> saveNote() async {
    errorMessage.value = null;
    isLoading.value = true;
    notifyListeners();

    if (titleController.text.isEmpty) {
      errorMessage.value = 'Título requerido';
      isLoading.value = false;
      notifyListeners();
      return false;
    }
    if (contentController.text.isEmpty) {
      errorMessage.value = 'Contenido requerido';
      isLoading.value = false;
      notifyListeners();
      return false;
    }

    try {
      final notesVm = NotesViewModel();
      final contenido = contentController.text;
      final titulo = titleController.text;
      await notesVm.createNote(titulo, contenido, idRecurso: selectedResourceId, esCompartida: isPublic);
      // Clear form
      titleController.clear();
      contentController.clear();
      tags.value = [];
      isPublic = false;
      setSelectedResource(null, null);
      return true;
    } catch (e) {
      errorMessage.value = 'Error al guardar nota: $e';
      return false;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }
}


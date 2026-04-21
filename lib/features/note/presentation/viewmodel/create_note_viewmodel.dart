import 'package:flutter/material.dart';
import 'package:academix/features/note/domain/usecases/note_usecases.dart';

/// ViewModel para la pantalla de creación de nota.
/// Recibe el use case por constructor; NO instancia repos ni datasources.
class CreateNoteViewModel extends ChangeNotifier {
  final CreateNoteUseCase _createNoteUseCase;

  CreateNoteViewModel({required CreateNoteUseCase createNoteUseCase})
      : _createNoteUseCase = createNoteUseCase;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ValueNotifier<List<String>> tags = ValueNotifier<List<String>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<String?> selectedResourceTitle =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasResource = ValueNotifier<bool>(false);

  bool isPublic = false;
  int? selectedResourceId;

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
    final trimmed = tag.trim().toLowerCase();
    if (trimmed.isNotEmpty && !tags.value.contains(trimmed)) {
      tags.value = [...tags.value, trimmed];
    }
  }

  void removeTag(String tag) {
    tags.value = tags.value.where((t) => t != tag).toList();
  }

  void setSelectedResource(int? id, String? title) {
    selectedResourceId = id;
    selectedResourceTitle.value = title;
    hasResource.value = id != null;
    notifyListeners();
  }

  /// Guarda la nota usando el use case.
  /// La validación de negocio está en CreateNoteUseCase; aquí solo manejamos
  /// estado de UI (loading, error).
  Future<bool> saveNote() async {
    errorMessage.value = null;
    isLoading.value = true;

    try {
      await _createNoteUseCase(
        titulo: titleController.text,
        contenido: contentController.text,
        idRecurso: selectedResourceId,
        esCompartida: isPublic,
      );
      _resetForm();
      return true;
    } on ArgumentError catch (e) {
      // Errores de validación de negocio (lanzados por el use case)
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Error al guardar nota: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    titleController.clear();
    contentController.clear();
    tags.value = [];
    isPublic = false;
    setSelectedResource(null, null);
  }
}
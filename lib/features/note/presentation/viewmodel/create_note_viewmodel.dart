import 'package:flutter/material.dart';

class CreateNoteViewModel extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ValueNotifier<List<String>> tags = ValueNotifier<List<String>>([]);
  bool isPublic = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    tags.dispose();
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

  Future<bool> saveNote() async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    // Mock validation
    if (titleController.text.isEmpty) {
      errorMessage = 'Título requerido';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (contentController.text.isEmpty) {
      errorMessage = 'Contenido requerido';
      isLoading = false;
      notifyListeners();
      return false;
    }

    // Mock API
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Nota guardada: ${titleController.text}, Public: $isPublic, Tags: ${tags.value}');

    isLoading = false;
    notifyListeners();
    return true;
  }
}


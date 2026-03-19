import 'package:flutter/material.dart';

class ExamHistoryViewModel extends ChangeNotifier {
  final ValueNotifier<List<dynamic>> history = ValueNotifier([]); // CompletedExamItem
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  ExamHistoryViewModel();

  Future<void> loadHistory() async {
    isLoading.value = true;
    // Mock data using existing entities
    await Future.delayed(const Duration(milliseconds: 500));
    history.value = [
      {'title': 'Álgebra Básica', 'score': 92, 'date': '2024-10-01', 'tema': 'Matemáticas'},
      {'title': 'Historia de México', 'score': 78, 'date': '2024-09-28', 'tema': 'Historia'},
      {'title': 'Biología Celular', 'score': 65, 'date': '2024-09-25', 'tema': 'Biología'},
    ];
    isLoading.value = false;
    notifyListeners();
  }

  @override
  void dispose() {
    history.dispose();
    isLoading.dispose();
    super.dispose();
  }
}

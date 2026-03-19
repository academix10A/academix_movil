import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/tema/domain/entities/tema_entity.dart';
import 'package:academix/features/tema/domain/entities/subtema_entity.dart';

class TemasViewModel extends ChangeNotifier {
  final ValueNotifier<List<TemaEntity>> temas = ValueNotifier([]);
  final ValueNotifier<List<SubtemaEntity>> subtemas = ValueNotifier([]);
  final ValueNotifier<String?> selectedTema = ValueNotifier(null);
  bool isLoading = false;

  TemasViewModel() {
    loadTemas();
  }

  Future<void> loadTemas() async {
    isLoading = true;
    notifyListeners();

    // Mock data
    await Future.delayed(const Duration(milliseconds: 500));
    temas.value = [
      TemaEntity(
        id: '1',
        title: 'Matemáticas',
        description: 'Álgebra, geometría, cálculo',
        subtemas: ['Álgebra', 'Geometría', 'Trigonometría'],
      ),
      TemaEntity(
        id: '2',
        title: 'Historia',
        description: 'Historia universal y de México',
        subtemas: ['México Colonial', 'Independencia', 'Revolución'],
      ),
      TemaEntity(
        id: '3',
        title: 'Biología',
        description: 'Células, ecosistemas, genética',
        subtemas: ['Células', 'Genética', 'Ecosistemas'],
      ),
    ];

    isLoading = false;
    notifyListeners();
  }

  void selectTema(String temaId, String temaTitle, BuildContext context) {
    AppNavigator.push(context, AppRoutes.temaDetail, arguments: {'temaId': temaId, 'temaTitle': temaTitle});
  }

  @override
  void dispose() {
    temas.dispose();
    subtemas.dispose();
    selectedTema.dispose();
    super.dispose();
  }
}


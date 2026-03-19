import 'package:flutter/material.dart';
import '../../domain/entities/subtema_entity.dart';
import '../../domain/usecases/get_subtemas_usecase.dart';

class SubtemaViewModel extends ChangeNotifier {
  String? selectedTemaId;
  
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<SubtemaEntity>> subtemas = ValueNotifier([]);
  final ValueNotifier<String?> selectedSubtemaId = ValueNotifier(null);

  SubtemaViewModel();

  Future<void> init(String temaId) async {
    selectedTemaId = temaId;
    await loadSubtemas();
  }

  Future<void> loadSubtemas() async {
    if (selectedTemaId == null) return;
    isLoading.value = true;
    try {
      final getSubtemasUseCase = GetSubtemasUseCase();
      final fetched = await getSubtemasUseCase.call(selectedTemaId!);
      subtemas.value = fetched;
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
    notifyListeners();
  }

  void selectSubtema(String subtemaId, BuildContext context) {
    selectedSubtemaId.value = subtemaId;
    // Nav to library filtered
    // AppNavigator.push(context, AppRoutes.library, arguments: {'subtemaId': subtemaId});
  }

  @override
  void dispose() {
    isLoading.dispose();
    subtemas.dispose();
    selectedSubtemaId.dispose();
    super.dispose();
  }
}

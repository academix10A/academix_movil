import 'package:flutter/material.dart';
import '../../domain/entities/offline_entity.dart';
import '../../domain/usecases/save_offline_usecase.dart';
import '../../domain/usecases/delete_offline_usecase.dart';
import '../../domain/usecases/check_offline_usecase.dart';
import '../../domain/usecases/list_offline_usecase.dart';

class OfflineViewModel {
  final SaveOfflineUseCase   saveUseCase;
  final DeleteOfflineUseCase deleteUseCase;
  final CheckOfflineUseCase  checkUseCase;
  final ListOfflineUseCase   listUseCase;

  OfflineViewModel({
    required this.saveUseCase,
    required this.deleteUseCase,
    required this.checkUseCase,
    required this.listUseCase,
  }) {
    cargarLista();
  }

  final ValueNotifier<List<OfflineEntity>> offlineItems =
      ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> cargarLista() async {
    isLoading.value = true;
    try {
      offlineItems.value = await listUseCase();
    } finally {
      isLoading.value = false;
    }
  }

  // Llamado desde OfflineButton
  Future<void> guardar(Map<String, dynamic> recurso) async {
    await saveUseCase(recurso);
    await cargarLista();
  }

  Future<void> eliminar(int idRecurso, String? urlArchivo) async {
    await deleteUseCase(idRecurso, urlArchivo);
    await cargarLista();
  }

  Future<bool> estaGuardado(int idRecurso) =>
      checkUseCase(idRecurso);

  void dispose() {
    offlineItems.dispose();
    isLoading.dispose();
  }
}
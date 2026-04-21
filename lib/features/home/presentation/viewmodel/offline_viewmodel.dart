import 'package:flutter/material.dart';
import 'package:academix/features/home/data/datasources/offline_local_datasource.dart';
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

  final ValueNotifier<List<OfflineEntity>> offlineItems = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> cargarLista() async {
    isLoading.value = true;
    try {
      offlineItems.value = await listUseCase();
    } finally {
      isLoading.value = false;
    }
  }

  /// Guarda el recurso offline.
  /// Retorna [GuardarResultado] para que la UI pueda mostrar advertencias
  /// si la descarga del PDF falló pero el recurso sí se guardó en la BD.
  Future<GuardarResultado> guardar(Map<String, dynamic> recurso) async {
    final resultado = await saveUseCase(recurso);
    await cargarLista();
    return resultado;
  }

  Future<void> eliminar(int idRecurso, String? urlArchivo) async {
    await deleteUseCase(idRecurso, urlArchivo);
    await cargarLista();
  }

  Future<bool> estaGuardado(int idRecurso) => checkUseCase(idRecurso);

  void dispose() {
    offlineItems.dispose();
    isLoading.dispose();
  }
}
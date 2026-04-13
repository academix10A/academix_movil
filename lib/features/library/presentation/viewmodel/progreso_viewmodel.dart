import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/progreso_entity.dart';
import '../../domain/repositories/progreso_repository.dart';

const _intervaloSync = Duration(seconds: 30);

class ProgresoViewModel {
  final ProgresoRepository repository;
  final int idRecurso;

  ProgresoViewModel({required this.repository, required this.idRecurso});

  final ValueNotifier<double> porcentaje  = ValueNotifier(0);
  final ValueNotifier<bool>   completado  = ValueNotifier(false);
  final ValueNotifier<int>    ultimaPos   = ValueNotifier(0);

  // Controlador de scroll que la View conecta al SingleChildScrollView
  final ScrollController scrollController = ScrollController();

  Timer?  _syncTimer;
  bool    _completadoInterno = false;
  bool    _cargando          = true;

  Future<void> cargar() async {
    try {
      final progreso = await repository.obtener(idRecurso);
      if (progreso != null) {
        porcentaje.value       = progreso.porcentajeLeido;
        completado.value       = progreso.completado;
        ultimaPos.value        = progreso.ultimaPosicion;
        _completadoInterno     = progreso.completado;
      }
    } catch (_) {}
    _cargando = false;
    _iniciarSync();
  }

  /// Llama esto después de que el scroll está montado
  /// para restaurar la posición donde el usuario quedó
  void restaurarPosicion() {
    final pos = ultimaPos.value;
    if (pos <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients &&
          scrollController.position.maxScrollExtent > 0) {
        scrollController.jumpTo(
          pos.toDouble().clamp(
            0,
            scrollController.position.maxScrollExtent,
          ),
        );
      }
    });
  }

  void _iniciarSync() {
    _syncTimer = Timer.periodic(_intervaloSync, (_) {
      if (!_completadoInterno) _enviarProgreso(false);
    });
    // También sincroniza al hacer scroll (debounced en la view)
  }

  // Calcula porcentaje desde posición de scroll actual
  void _enviarProgreso(bool esCompletado) {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final offset    = scrollController.offset;

    final pct = maxScroll > 0
        ? (offset / maxScroll * 100).clamp(0, 99).roundToDouble()
        : 0.0;

    final pctFinal = esCompletado ? 100.0 : pct;

    porcentaje.value  = pctFinal;
    ultimaPos.value   = offset.toInt();

    repository.actualizar(
      idRecurso,
      porcentajeLeido: pctFinal,
      ultimaPosicion:  offset.toInt(),
      completado:      esCompletado,
    ).catchError((_) {});
  }

  void marcarCompletado() {
    if (_completadoInterno) return;
    _completadoInterno  = true;
    completado.value    = true;
    _enviarProgreso(true);
  }

  /// Llama al cerrar la pantalla para sincronizar la posición final
  void sincronizarAlSalir() {
    if (!_completadoInterno) _enviarProgreso(false);
  }

  void dispose() {
    _syncTimer?.cancel();
    scrollController.dispose();
    porcentaje.dispose();
    completado.dispose();
    ultimaPos.dispose();
  }
}
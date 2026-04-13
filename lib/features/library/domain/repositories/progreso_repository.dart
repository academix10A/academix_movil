import '../entities/progreso_entity.dart';

abstract class ProgresoRepository {
  Future<ProgresoEntity?> obtener(int idRecurso);
  Future<void> actualizar(
    int idRecurso, {
    required double porcentajeLeido,
    required int    ultimaPosicion,
    required bool   completado,
  });
}
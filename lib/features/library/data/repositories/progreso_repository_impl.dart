import '../../domain/entities/progreso_entity.dart';
import '../../domain/repositories/progreso_repository.dart';
import '../datasources/progreso_remote_datasource.dart';

class ProgresoRepositoryImpl implements ProgresoRepository {
  final ProgresoRemoteDataSource remote;

  ProgresoRepositoryImpl(this.remote);

  @override
  Future<ProgresoEntity?> obtener(int idRecurso) async {
    final data = await remote.obtenerProgreso(idRecurso);
    if (data == null) return null;
    return ProgresoEntity(
      porcentajeLeido: (data['porcentaje_leido'] as num?)?.toDouble() ?? 0,
      ultimaPosicion:  (data['ultima_posicion']  as int?)            ?? 0,
      completado:      (data['completado']        as bool?)           ?? false,
    );
  }

  @override
  Future<void> actualizar(
    int idRecurso, {
    required double porcentajeLeido,
    required int    ultimaPosicion,
    required bool   completado,
  }) async {
    await remote.actualizarProgreso(
      idRecurso,
      porcentajeLeido: porcentajeLeido,
      ultimaPosicion:  ultimaPosicion,
      completado:      completado,
    );
  }
}
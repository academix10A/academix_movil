import '../../domain/entities/offline_entity.dart';
import '../../domain/repositories/offline_repository.dart';
import '../datasources/offline_local_datasource.dart';
import '../datasources/offline_remote_datasource.dart';

class OfflineRepositoryImpl implements OfflineRepository {
  final OfflineLocalDataSource  local;
  final OfflineRemoteDataSource remote;

  OfflineRepositoryImpl({required this.local, required this.remote});

  @override
  Future<void> guardar(Map<String, dynamic> recursoBase) async {
    final idRecurso = recursoBase['id_recurso'] as int;

    // 1. Registra en backend
    await remote.registrar(idRecurso);

    // 2. Fetch del recurso completo para obtener contenido
    //    Si falla (sin internet), usa lo que ya tenemos en recursoBase
    Map<String, dynamic> recursoCompleto;
    try {
      recursoCompleto = await remote.obtenerRecursoCompleto(idRecurso);
    } catch (_) {
      recursoCompleto = recursoBase;
    }

    // 3. Guarda metadata completa (con contenido) en SQLite
    await local.guardarMetadata({
      'id_recurso':  idRecurso,
      'titulo':      recursoCompleto['titulo']      ?? recursoBase['titulo']      ?? '',
      'descripcion': recursoCompleto['descripcion'] ?? recursoBase['descripcion'] ?? '',
      'contenido':   recursoCompleto['contenido']   ?? recursoBase['contenido'],
      'url_archivo': recursoCompleto['url_archivo'] ?? recursoBase['url_archivo'],
      'id_subtema':  recursoCompleto['id_subtema']  ?? recursoBase['id_subtema'],
      'id_tipo':     recursoCompleto['id_tipo']     ?? recursoBase['id_tipo'],
      'external_id': recursoCompleto['external_id'] ?? recursoBase['external_id'],
    });
  }

  @override
  Future<void> eliminar(int idRecurso, String? urlArchivo) async {
    await remote.eliminar(idRecurso);
    await local.eliminarMetadata(idRecurso);
  }

  @override
  Future<bool> estaGuardado(int idRecurso) async {
    final metadata = await local.obtenerMetadata(idRecurso);
    return metadata != null;
  }

  @override
  Future<List<OfflineEntity>> listarTodos() async {
    final rows = await local.listarTodos();
    return rows.map((r) => OfflineEntity(
      idRecurso:     r['id_recurso']   as int,
      titulo:        r['titulo']        as String,
      descripcion:   (r['descripcion'] as String?) ?? '',
      urlArchivo:    r['url_archivo']  as String?,
      contenido:     r['contenido']    as String?,
      idTipo:        r['id_tipo']      as int?,
      idSubtema:     r['id_subtema']   as int?,
      externalId:    r['external_id']  as String?,
      fechaDescarga: DateTime.parse(r['fecha_descarga'] as String),
    )).toList();
  }
}
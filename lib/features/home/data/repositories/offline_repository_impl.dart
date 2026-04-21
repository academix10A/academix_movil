import 'dart:typed_data';
import 'package:academix/features/home/data/datasources/offline_local_datasource.dart';
import 'package:academix/features/home/data/datasources/offline_remote_datasource.dart';
import 'package:academix/features/home/domain/entities/offline_entity.dart';
import 'package:academix/features/home/domain/repositories/offline_repository.dart';

class OfflineRepositoryImpl implements OfflineRepository {
  final OfflineLocalDataSource  local;
  final OfflineRemoteDataSource remote;

  OfflineRepositoryImpl({required this.local, required this.remote});

  // Retorna GuardarResultado para que SaveOfflineUseCase lo propague a la UI.
  // El remote.registrar va primero; si falla con 409 (ya existe) se ignora.
  Future<GuardarResultado> guardarConResultado(
      Map<String, dynamic> recurso) async {
    try {
      await remote.registrar(recurso['id_recurso'] as int);
    } catch (_) {}
    return local.guardarMetadata(recurso);
  }

  // Mantiene la firma void del OfflineRepository para no romper otros use cases
  @override
  Future<void> guardar(Map<String, dynamic> recurso) =>
      guardarConResultado(recurso);

  @override
  Future<void> eliminar(int idRecurso, String? urlArchivo) async {
    await local.eliminarMetadata(idRecurso);
    try {
      await remote.eliminar(idRecurso);
    } catch (_) {}
  }

  @override
  Future<bool> estaGuardado(int idRecurso) async {
    final meta = await local.obtenerMetadata(idRecurso);
    return meta != null;
  }

  @override
  Future<List<OfflineEntity>> listarTodos() async {
    final rows = await local.listarTodos();
    return rows.map(_fromMap).toList();
  }

  Future<Uint8List?> leerPdfLocal(int idRecurso, String rutaLocal) =>
      local.leerPdfLocal(idRecurso, rutaLocal);

  OfflineEntity _fromMap(Map<String, dynamic> map) => OfflineEntity(
    idRecurso:     map['id_recurso']    as int,
    titulo:        map['titulo']        as String,
    descripcion:   (map['descripcion']  as String?) ?? '',
    urlArchivo:    map['url_archivo']   as String?,
    rutaLocal:     map['ruta_local']    as String?,
    contenido:     map['contenido']     as String?,
    idTipo:        map['id_tipo']       as int?,
    idSubtema:     map['id_subtema']    as int?,
    externalId:    map['external_id']   as String?,
    fechaDescarga: DateTime.parse(map['fecha_descarga'] as String),
  );
}
import '../entities/offline_entity.dart';

abstract class OfflineRepository {
  Future<void> guardar(Map<String, dynamic> recurso);
  Future<void> eliminar(int idRecurso, String? urlArchivo);
  Future<bool> estaGuardado(int idRecurso);
  Future<List<OfflineEntity>> listarTodos();
}
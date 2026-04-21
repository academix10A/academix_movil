import 'package:academix/features/home/data/datasources/offline_local_datasource.dart';
import 'package:academix/features/home/data/repositories/offline_repository_impl.dart';

class SaveOfflineUseCase {
  final OfflineRepositoryImpl _repo;

  SaveOfflineUseCase(this._repo);

  Future<GuardarResultado> call(Map<String, dynamic> recurso) =>
      _repo.guardarConResultado(recurso);
}
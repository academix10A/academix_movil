import 'package:academix/features/home/data/datasources/offline_local_datasource.dart';
import 'package:academix/features/home/data/datasources/offline_remote_datasource.dart';
import 'package:academix/features/home/data/repositories/offline_repository_impl.dart';
import 'package:academix/features/home/domain/usecases/save_offline_usecase.dart';
import 'package:academix/features/home/domain/usecases/delete_offline_usecase.dart';
import 'package:academix/features/home/domain/usecases/check_offline_usecase.dart';
import 'package:academix/features/home/domain/usecases/list_offline_usecase.dart';
import 'offline_viewmodel.dart';

class OfflineDI {
  OfflineDI._();

  static OfflineRepositoryImpl _repository() => OfflineRepositoryImpl(
        local:  OfflineLocalDataSource(),
        remote: OfflineRemoteDataSource(),
      );

  static OfflineViewModel viewModel() {
    final repo = _repository();
    return OfflineViewModel(
      saveUseCase:   SaveOfflineUseCase(repo),
      deleteUseCase: DeleteOfflineUseCase(repo),
      checkUseCase:  CheckOfflineUseCase(repo),
      listUseCase:   ListOfflineUseCase(repo),
    );
  }
}
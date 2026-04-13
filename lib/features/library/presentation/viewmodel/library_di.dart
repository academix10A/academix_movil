import 'package:academix/features/library/data/datasources/library_remote_datasource.dart';
import 'package:academix/features/library/data/datasources/search_remote_datasource.dart';
import 'package:academix/features/library/data/repositories/library_repository_impl.dart';
import 'package:academix/features/library/domain/usecases/get_favorites_usecase.dart';
import 'package:academix/features/library/domain/usecases/get_resource_by_id_usecase.dart';
import 'package:academix/features/library/domain/usecases/get_resources_from_temas_usecase.dart';
import 'package:academix/features/library/domain/usecases/toggle_favorite_usecase.dart';
import 'package:academix/features/library/presentation/viewmodel/book_detail_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/search_viewmodel.dart';
import 'package:academix/features/library/data/datasources/publication_remote_datasource.dart';
import 'package:academix/features/library/data/repositories/publication_repository_impl.dart';
import 'package:academix/features/library/domain/usecases/get_publication_by_id_usecase.dart';
import 'package:academix/features/library/presentation/viewmodel/publication_detail_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/progreso_viewmodel.dart';
import 'package:academix/features/library/data/repositories/progreso_repository_impl.dart';
import 'package:academix/features/library/data/datasources/progreso_remote_datasource.dart';

/// Assembles the full dependency graph for the library feature.
/// Call these factory methods from initState() in each Screen.
///
/// In larger apps replace this with get_it, riverpod, or injectable.
class LibraryDI {
  LibraryDI._();

  static LibraryRemoteDataSource _datasource() => LibraryRemoteDataSource();

  static LibraryRepositoryImpl _repository() =>
      LibraryRepositoryImpl(_datasource());

  static LibraryViewModel libraryViewModel({required int idUsuario}) {
    final repo = _repository();
    return LibraryViewModel(
      getResourcesFromTemasUseCase: GetResourcesFromTemasUseCase(repo),
      getFavoritesUseCase: GetFavoritesUseCase(repo),
      toggleFavoriteUseCase: ToggleFavoriteUseCase(repo),
      idUsuario: idUsuario,
    );
  }

  static BookDetailViewModel bookDetailViewModel({required int idUsuario}) {
    final repo = _repository();
    return BookDetailViewModel(
      getResourceByIdUseCase: GetResourceByIdUseCase(repo),
      getFavoritesUseCase: GetFavoritesUseCase(repo),
      toggleFavoriteUseCase: ToggleFavoriteUseCase(repo),
      idUsuario: idUsuario,
    );
  }

  static SearchViewModel searchViewModel() {
    return SearchViewModel(searchDataSource: SearchRemoteDataSource());
  }

  static ProgresoViewModel progresoViewModel({required int idRecurso}) {
    final repo = ProgresoRepositoryImpl(ProgresoRemoteDataSource());
    return ProgresoViewModel(repository: repo, idRecurso: idRecurso);
  }

  static PublicationDetailViewModel publicationDetailViewModel() {
    final repo = PublicationRepositoryImpl(PublicationRemoteDataSource());
    return PublicationDetailViewModel(
      getPublicationByIdUseCase: GetPublicationByIdUseCase(repo),
    );
  }
}

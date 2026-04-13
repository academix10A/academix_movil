import 'package:academix/features/publication/data/datasources/publication_remote_datasource.dart';
import 'package:academix/features/publication/data/repositories/publication_repository_impl.dart';
import 'package:academix/features/publication/domain/usecases/create_publication_usecase.dart';
import 'package:academix/features/publication/domain/usecases/delete_publication_usecase.dart';
import 'package:academix/features/publication/domain/usecases/get_my_publications_usecase.dart';
import 'package:academix/features/publication/domain/usecases/update_publication_usecase.dart';
import 'package:academix/features/publication/presentation/viewmodel/create_edit_publication_viewmodel.dart';
import 'package:academix/features/publication/presentation/viewmodel/publications_viewmodel.dart';

class PublicationDI {
  PublicationDI._();

  static PublicationRepositoryImpl _repository() =>
      PublicationRepositoryImpl(PublicationRemoteDataSource());

  static PublicationsViewModel publicationsViewModel() {
    final repo = _repository();
    return PublicationsViewModel(
      getMyPublicationsUseCase: GetMyPublicationsUseCase(repo),
      deletePublicationUseCase: DeletePublicationUseCase(repo),
    );
  }

  static CreateEditPublicationViewModel createEditPublicationViewModel() {
    final repo = _repository();
    return CreateEditPublicationViewModel(
      createPublicationUseCase: CreatePublicationUseCase(repo),
      updatePublicationUseCase: UpdatePublicationUseCase(repo),
    );
  }
}
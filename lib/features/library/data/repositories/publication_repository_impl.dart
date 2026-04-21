import 'package:academix/features/library/data/datasources/publication_remote_datasource.dart';
import 'package:academix/features/library/domain/entities/publication_entity.dart';
import 'package:academix/features/library/domain/repositories/publication_repository.dart';

class PublicationRepositoryImpl implements PublicationRepository {
  final PublicationRemoteDataSource remoteDataSource;

  const PublicationRepositoryImpl(this.remoteDataSource);

@override
  Future<PublicationEntity> getPublicationById(int id) async {
    final model = await remoteDataSource.getPublicationById(id);
    return model.entity;
  }
}



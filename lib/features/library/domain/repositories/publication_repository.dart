import 'package:academix/features/library/domain/entities/publication_entity.dart';

abstract class PublicationRepository {
  Future<PublicationEntity> getPublicationById(int id);
}


import 'package:dartz/dartz.dart';
import 'package:academix/core/errors/failures.dart';
import 'package:academix/features/library/domain/entities/publication_entity.dart';
import 'package:academix/features/library/domain/repositories/publication_repository.dart';

class GetPublicationByIdUseCase {
  final PublicationRepository repository;

  GetPublicationByIdUseCase(this.repository);

  Future<Either<Failure, PublicationEntity>> call(int id) async {
    try {
      final publication = await repository.getPublicationById(id);
      return Right(publication);
    } catch (e) {
      return Left(ServerFailure("Error: $e"));
    }
  }
}


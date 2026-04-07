import '../repositories/library_repository.dart';

class ToggleFavoriteUseCase {
  final LibraryRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> call({
    required int idUsuario,
    required int idRecurso,
    required bool isCurrentlyFavorite,
  }) {
    if (isCurrentlyFavorite) {
      return repository.deleteFavorite(idUsuario, idRecurso);
    } else {
      return repository.postFavorite(idUsuario, idRecurso);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:academix/core/errors/failures.dart';
import '../../domain/entities/publication_entity.dart';
import '../../domain/usecases/get_my_publications_usecase.dart';
import '../../domain/usecases/delete_publication_usecase.dart';

class PublicationsViewModel extends ChangeNotifier {
  final GetMyPublicationsUseCase getMyPublicationsUseCase;
  final DeletePublicationUseCase deletePublicationUseCase;
  bool _isDisposed = false;

  PublicationsViewModel({
    required this.getMyPublicationsUseCase,
    required this.deletePublicationUseCase,
  });

  final ValueNotifier<List<PublicationEntity>> publications = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<void> loadPublications() async {
    if (_isDisposed) return;
    isLoading.value = true;
    error.value = null;
    try {
      final result = await getMyPublicationsUseCase();
      if (_isDisposed) return;
      publications.value = result;
    } on Failure {
      if (_isDisposed) return;
      error.value = 'Error al cargar publicaciones';
    } catch (e) {
      if (_isDisposed) return;
      error.value = 'Error inesperado: $e';
    } finally {
      if (_isDisposed) return;
      isLoading.value = false;
    }
  }

  Future<void> deletePublication(int id) async {
    if (_isDisposed) return;
    isLoading.value = true;
    error.value = null;
    try {
      await deletePublicationUseCase(id);
      if (_isDisposed) return;
      publications.value = publications.value.where((p) => p.id != id).toList();
    } on Failure {
      if (_isDisposed) return;
      error.value = 'Error al eliminar publicación';
    } catch (e) {
      if (_isDisposed) return;
      error.value = 'Error al eliminar: $e';
    } finally {
      if (_isDisposed) return;
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    publications.dispose();
    isLoading.dispose();
    error.dispose();
    super.dispose();
  }
}
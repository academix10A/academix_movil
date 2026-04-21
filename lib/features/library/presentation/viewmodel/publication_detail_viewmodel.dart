import 'package:flutter/material.dart';
import 'package:academix/features/library/domain/usecases/get_publication_by_id_usecase.dart';
import 'package:academix/features/library/domain/entities/publication_entity.dart';

class PublicationDetailViewModel extends ChangeNotifier {
  final GetPublicationByIdUseCase getPublicationByIdUseCase;

  PublicationDetailViewModel({required this.getPublicationByIdUseCase});

  final ValueNotifier<PublicationEntity?> publication = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<void> loadPublication(int id) async {
    isLoading.value = true;
    error.value = null;
    try {
      final result = await getPublicationByIdUseCase(id);
      result.fold(
        (failure) {
          error.value = failure.toString();
        },
        (data) {
          publication.value = data;
        },
      );
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    publication.dispose();
    isLoading.dispose();
    error.dispose();
    super.dispose();
  }
}


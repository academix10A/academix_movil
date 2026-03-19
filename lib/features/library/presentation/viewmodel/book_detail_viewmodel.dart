import 'package:flutter/material.dart';
import 'package:academix/features/library/domain/entities/library_entity.dart';
import 'package:academix/features/library/data/datasources/library_remote_datasource.dart';

class BookDetailViewModel {
  final ValueNotifier<LibraryResourceEntity?> resource =
      ValueNotifier(null);

  final ValueNotifier<bool> isLoading = ValueNotifier(true);

  final LibraryRemoteDataSource _remoteDataSource =
      LibraryRemoteDataSource();

  Future<void> loadResource(int id) async {
    try {
      isLoading.value = true;

      final data = await _remoteDataSource.getRecursoById(id);

      resource.value = data;
    } catch (e) {
      resource.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    resource.dispose();
    isLoading.dispose();
  }
}
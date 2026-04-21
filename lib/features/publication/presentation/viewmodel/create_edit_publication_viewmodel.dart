import 'dart:async';
import 'package:flutter/material.dart';
import 'package:academix/core/errors/failures.dart';
import '../../domain/usecases/create_publication_usecase.dart';
import '../../domain/usecases/update_publication_usecase.dart';
import 'package:academix/features/publication/domain/entities/publication_entity.dart';

class CreateEditPublicationViewModel extends ChangeNotifier {
  final CreatePublicationUseCase createPublicationUseCase;
  final UpdatePublicationUseCase updatePublicationUseCase;

  CreateEditPublicationViewModel({
    required this.createPublicationUseCase,
    required this.updatePublicationUseCase,
  });

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);
  final ValueNotifier<bool> isSuccess = ValueNotifier(false);

  // Controllers
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController textoController = TextEditingController();
  final TextEditingController etiquetasController = TextEditingController();

  Future<bool> createPublication() async {
    isLoading.value = true;
    error.value = null;
    isSuccess.value = false;
    notifyListeners();

    try {
      // final data = {
      //   'titulo': tituloController.text.trim(),
      //   'descripcion': descripcionController.text.trim(),
      //   'texto': textoController.text.trim(),
      //   'etiquetas': etiquetasController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      // };

      // if ((data['titulo'] as String).isEmpty || (data['texto'] as String).isEmpty){
      //   error.value = 'Título y texto son requeridos';
      //   isLoading.value = false;
      //   notifyListeners();
      //   return false;
      // }

      final titulo = tituloController.text.trim();
      final texto = textoController.text.trim();

      if (titulo.isEmpty || texto.isEmpty) {
        error.value = 'Título y texto son requeridos';
        isLoading.value = false;
        notifyListeners();
        return false;
      }

      final data = {
        'titulo': titulo,
        'descripcion': descripcionController.text.trim(),
        'texto': texto,
        'etiquetas': etiquetasController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      };

      await createPublicationUseCase(data);
      isSuccess.value = true;
      return true;
    } on Failure catch (f) {
      error.value = f.message;
      return false;
    } catch (e) {
      error.value = 'Error al crear: $e';
      return false;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  Future<bool> updatePublication(int id) async {
    isLoading.value = true;
    error.value = null;
    isSuccess.value = false;
    notifyListeners();

    try {
      // final data = {
      //   'titulo': tituloController.text.trim(),
      //   'descripcion': descripcionController.text.trim(),
      //   'texto': textoController.text.trim(),
      //   'etiquetas': etiquetasController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      // };

      // if (data['titulo']!.isEmpty || data['texto']!.isEmpty) {
      //   error.value = 'Título y texto son requeridos';
      //   isLoading.value = false;
      //   notifyListeners();
      //   return false;
      // }

      final titulo = tituloController.text.trim();
      final texto = textoController.text.trim();

      if (titulo.isEmpty || texto.isEmpty) {
        error.value = 'Título y texto son requeridos';
        isLoading.value = false;
        notifyListeners();
        return false;
      }

      final data = {
        'titulo': titulo,
        'descripcion': descripcionController.text.trim(),
        'texto': texto,
        'etiquetas': etiquetasController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      };

      await updatePublicationUseCase(id, data);
      isSuccess.value = true;
      return true;
    } on Failure catch (f) {
      error.value = f.message;
      return false;
    } catch (e) {
      error.value = 'Error al actualizar: $e';
      return false;
    } finally {
      isLoading.value = false;
      notifyListeners();
    }
  }

  void loadPublication(PublicationEntity pub) {
    tituloController.text = pub.titulo;
    descripcionController.text = pub.descripcion;
    textoController.text = pub.texto;
    etiquetasController.text = pub.etiquetas?.join(', ') ?? '';
    notifyListeners();
  }

  @override
  void dispose() {
    isLoading.dispose();
    error.dispose();
    isSuccess.dispose();
    tituloController.dispose();
    descripcionController.dispose();
    textoController.dispose();
    etiquetasController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/membresia_entity.dart';
import '../../domain/usecases/membresia_usecases.dart';

class MembresiaViewModel extends ChangeNotifier {
  final GetMembresiasUseCase _getMembresias;

  MembresiaViewModel({required GetMembresiasUseCase getMembresias})
      : _getMembresias = getMembresias;

  List<Membresia> _membresias = [];
  bool _isLoading = false;
  String? _error;

  List<Membresia> get membresias => _membresias;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMembresias() async {
    _isLoading = true;
    notifyListeners();

    try {
      _membresias = await _getMembresias();
    } catch (e) {
      _error = 'Error al cargar membresías';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
import 'package:flutter/material.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../domain/entities/membresia_entity.dart';

class MembresiaViewModel extends ChangeNotifier {
  final ProfileRemoteDataSource _dataSource = ProfileRemoteDataSource();

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
      _membresias = await _dataSource.getMembresias();
    } catch (e) {
      _error = 'Error al cargar membresías';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
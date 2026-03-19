import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/core/storage/session_manager.dart';
import 'package:academix/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:academix/features/profile/domain/entities/profile_entity.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRemoteDataSource _dataSource = ProfileRemoteDataSource();
  
  UserProfileEntity? _user;
  UserStatsEntity? _stats;
  int _resourcesCount = 0;
  int _notesCount = 0; // Will be updated when notes endpoint is available
  bool _isPremium = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfileEntity? get user => _user;
  UserStatsEntity? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPremium => _isPremium;
  int get resourcesCount => _resourcesCount;
  int get notesCount => _notesCount;
  int get examsCount => _stats?.totalExamenesRealizados ?? 0;

  /// Full name from API
  String get fullName => _user?.fullName ?? 'Cargando...';

  /// Email from API
  String get email => _user?.email ?? 'Cargando...';

  /// Initials from full name
  String get initials => _user?.initials ?? '??';

  /// Load all profile data from API
  Future<void> loadProfileData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Load user profile
      _user = await _dataSource.getCurrentUser();
      
      // Load stats in parallel
      final results = await Future.wait([
        _dataSource.getUserStats().catchError((_) => UserStatsEntity(
          totalExamenesRealizados: 0,
          examenesCompletados: 0,
          promedioCalificacion: 0.0,
        )),
        _dataSource.getResourcesCount().catchError((_) => 0),
      ]);
      
      _stats = results[0] as UserStatsEntity;
      _resourcesCount = results[1] as int;
      
      // TODO: Check membership status when endpoint is available
      // For now, set as non-premium (can be updated later)
      _isPremium = false;
      
    } catch (e) {
      _error = 'Error al cargar los datos del perfil';
      debugPrint('Error loading profile data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSettings() {
    debugPrint('Navigate to settings');
  }

  void onUpgradePremium() {
    debugPrint('Navigate to upgrade premium');
  }

  Future<void> onLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF20234A), // backgroundCard
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(color: Color(0xFFF0F2F5)),
        ),
        content: const Text(
          'Se cerrará tu sesión actual.',
          style: TextStyle(color: Color(0xFF9A9DB5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF9A9DB5)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              // Clear session before navigating
              await SessionManager.clearSession();
              
              // Navigate to login removing all previous routes
              if (context.mounted) {
                AppNavigator.pushReplacementUnique(
                  context,
                  AppRoutes.login,
                );
              }
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Color(0xFFFF5252),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

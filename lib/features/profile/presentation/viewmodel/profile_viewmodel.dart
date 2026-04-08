import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/core/storage/session_manager.dart';
import 'package:academix/features/profile/domain/entities/profile_entity.dart';
import 'package:academix/features/profile/domain/entities/membresia_entity.dart';
import 'package:academix/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:academix/features/profile/domain/usecases/get_stats_usecases.dart';
import 'package:academix/features/profile/domain/usecases/membresia_usecases.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetCurrentUserUseCase _getCurrentUser;
  final GetUserStatsUseCase _getUserStats;
  final GetResourcesCountUseCase _getResourcesCount;
  final GetNoteCountUseCase _getNoteCount;
  final ActivarMembresiaUseCase _activarMembresia;

  ProfileViewModel({
    required GetCurrentUserUseCase getCurrentUser,
    required GetUserStatsUseCase getUserStats,
    required GetResourcesCountUseCase getResourcesCount,
    required GetNoteCountUseCase getNoteCount,
    required ActivarMembresiaUseCase activarMembresia,
  })  : _getCurrentUser = getCurrentUser,
        _getUserStats = getUserStats,
        _getResourcesCount = getResourcesCount,
        _getNoteCount = getNoteCount,
        _activarMembresia = activarMembresia;

  UserProfileEntity? _user;
  UserStatsEntity? _stats;
  int _resourcesCount = 0;
  int _notesCount = 0;
  bool _isPremium = false;
  bool _isLoading = false;
  String? _error;

  UserProfileEntity? get user => _user;
  UserStatsEntity? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPremium => _isPremium;
  int get resourcesCount => _resourcesCount;
  int get notesCount => _notesCount;
  int get examsCount => _stats?.totalExamenesRealizados ?? 0;
  String get fullName => _user?.fullName ?? 'Cargando...';
  String get email => _user?.email ?? 'Cargando...';
  String get initials => _user?.initials ?? '??';

  Future<void> loadProfileData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _getCurrentUser();

      final results = await Future.wait([
        _getUserStats().catchError((_) => UserStatsEntity(
              totalExamenesRealizados: 0,
              examenesCompletados: 0,
              promedioCalificacion: 0.0,
            )),
        _getResourcesCount().catchError((_) => 0),
        _getNoteCount().catchError((_) => 0),
      ]);

      _stats = results[0] as UserStatsEntity;
      _resourcesCount = results[1] as int;
      _notesCount = results[2] as int;
      _isPremium = _user?.isPremium ?? false;
    } catch (e) {
      _error = 'Error al cargar los datos del perfil';
      debugPrint('Error loading profile data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await loadProfileData();
  }

  Future<void> purchaseMembresia(Membresia plan) async {
    try {
      await _activarMembresia(plan.id);
      await refreshProfile();
    } catch (e) {
      debugPrint('Error purchasing: $e');
      rethrow;
    }
  }

  Future<void> onLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF20234A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cerrar sesión?',
            style: TextStyle(color: Color(0xFFF0F2F5))),
        content: const Text('Se cerrará tu sesión actual.',
            style: TextStyle(color: Color(0xFF9A9DB5))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF9A9DB5))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SessionManager.clearSession();
              if (context.mounted) {
                AppNavigator.pushReplacementUnique(context, AppRoutes.login);
              }
            },
            child: const Text('Cerrar sesión',
                style: TextStyle(
                    color: Color(0xFFFF5252), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
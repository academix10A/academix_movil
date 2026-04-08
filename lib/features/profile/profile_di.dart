import 'package:academix/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:academix/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:academix/features/profile/domain/usecases/get_current_user_usecase.dart';
import 'package:academix/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:academix/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:academix/features/profile/domain/usecases/get_stats_usecases.dart';
import 'package:academix/features/profile/domain/usecases/membresia_usecases.dart';
import 'package:academix/features/profile/presentation/viewmodel/profile_viewmodel.dart';
import 'package:academix/features/profile/presentation/viewmodel/settings_viewmodel.dart';
import 'package:academix/features/profile/presentation/viewmodel/membresia_viewmodel.dart';

class ProfileDI {
  ProfileDI._();

  // ── Data ────────────────────────────────────────────────────────────────────
  static final _dataSource = ProfileRemoteDataSource();
  static final _repository = ProfileRepositoryImpl(_dataSource);

  // ── Use Cases (singletons — stateless, se pueden reutilizar) ────────────────
  static final _getCurrentUser = GetCurrentUserUseCase(_repository);
  static final _updateProfile = UpdateProfileUseCase(_repository);
  static final _changePassword = ChangePasswordUseCase(_repository);
  static final _getUserStats = GetUserStatsUseCase(_repository);
  static final _getResourcesCount = GetResourcesCountUseCase(_repository);
  static final _getNoteCount = GetNoteCountUseCase(_repository);
  static final _getMembresias = GetMembresiasUseCase(_repository);
  static final _activarMembresia = ActivarMembresiaUseCase(_repository);
  static final _createPaypalOrder = CreatePaypalOrderUseCase(_repository);
  static final _capturePaypalOrder = CapturePaypalOrderUseCase(_repository);

  // ── ViewModels (factory — nueva instancia por pantalla) ─────────────────────
  static ProfileViewModel get profileViewModel => ProfileViewModel(
        getCurrentUser: _getCurrentUser,
        getUserStats: _getUserStats,
        getResourcesCount: _getResourcesCount,
        getNoteCount: _getNoteCount,
        activarMembresia: _activarMembresia,
      );

  static SettingsViewModel get settingsViewModel => SettingsViewModel(
        getCurrentUser: _getCurrentUser,
        updateProfile: _updateProfile,
        changePassword: _changePassword,
      );

  static MembresiaViewModel get membresiaViewModel => MembresiaViewModel(
        getMembresias: _getMembresias,
      );

  // ── Use cases expuestos para PayPalWebView ───────────────────────────────────
  static CreatePaypalOrderUseCase get createPaypalOrder => _createPaypalOrder;
  static CapturePaypalOrderUseCase get capturePaypalOrder => _capturePaypalOrder;
  static ActivarMembresiaUseCase get activarMembresia => _activarMembresia;
}
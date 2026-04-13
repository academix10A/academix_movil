import 'package:flutter/material.dart';
import 'package:academix/features/exam/data/datasources/exam_remote_datasource.dart';
import 'package:academix/features/exam/data/repositories/exam_repository_impl.dart';
import 'package:academix/features/exam/domain/repositories/exam_repository.dart';
import 'package:academix/features/exam/domain/usecases/get_available_exams_usecase.dart';
import 'package:academix/features/exam/domain/usecases/get_completed_exams_usecase.dart';
import 'package:academix/features/exam/domain/usecases/get_exam_completo_usecase.dart';
import 'package:academix/features/exam/domain/usecases/get_mis_intentos_usecase.dart';
import 'package:academix/features/exam/domain/usecases/submit_exam_usecase.dart';
import 'package:academix/features/exam/domain/usecases/get_detailed_exams_premium_freemium_usecase.dart';

/// Contenedor de dependencias del módulo de exámenes.
///
/// Centraliza la construcción del grafo de dependencias:
///   DataSource → Repository → UseCases
///
/// En producción, reemplaza esto con get_it, riverpod, o Provider
/// para inyección verdadera en toda la app. Este archivo sirve como
/// referencia clara del árbol de dependencias del módulo.
class ExamDependencies {
  // ── Data layer ────────────────────────────────────────────────────────────
  late final ExamRemoteDataSource _remoteDataSource;
  late final ExamRepository _repository;

  // ── UseCases ──────────────────────────────────────────────────────────────
  late final GetAvailableExamsUseCase getAvailableExamsUseCase;
  late final GetDetailedExamsUseCase getDetailedExamsUseCase;
  late final GetDetailedExamsPremiumFreemiumUseCase getDetailedExamsPremiumFreemiumUseCase;
  late final GetCompletedExamsUseCase getCompletedExamsUseCase;
  late final GetExamCompletoUseCase getExamCompletoUseCase;
  late final GetMisIntentosUseCase getMisIntentosUseCase;
  late final SubmitExamUseCase submitExamUseCase;

  ExamDependencies() {
    // 1. DataSource (infraestructura)
    _remoteDataSource = ExamRemoteDataSource();

    // 2. Repository (implementación del contrato de dominio)
    _repository = ExamRepositoryImpl(_remoteDataSource);

    // 3. UseCases (lógica de negocio)
    getAvailableExamsUseCase = GetAvailableExamsUseCase(_repository);
    getDetailedExamsUseCase = GetDetailedExamsUseCase(_repository);
    getCompletedExamsUseCase = GetCompletedExamsUseCase(_repository);
    getExamCompletoUseCase = GetExamCompletoUseCase(_repository);
    getMisIntentosUseCase = GetMisIntentosUseCase(_repository);
    submitExamUseCase = SubmitExamUseCase(_repository);
    getDetailedExamsPremiumFreemiumUseCase = GetDetailedExamsPremiumFreemiumUseCase(_repository);
  }
}

// ── InheritedWidget para inyectar ExamDependencies en el árbol de widgets ────

class ExamDependenciesProvider extends InheritedWidget {
  final ExamDependencies dependencies;

  const ExamDependenciesProvider({
    super.key,
    required this.dependencies,
    required super.child,
  });

  static ExamDependencies of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ExamDependenciesProvider>();
    assert(provider != null,
        'ExamDependenciesProvider no encontrado en el árbol de widgets. '
        'Asegúrate de envolverlo sobre las pantallas del módulo de exámenes.');
    return provider!.dependencies;
  }

  @override
  bool updateShouldNotify(ExamDependenciesProvider oldWidget) => false;
}

/// Extension para acceder a las dependencias desde cualquier BuildContext
/// sin boilerplate extra.
///
/// Uso: `context.examDependencies.getAvailableExamsUseCase`
extension ExamDependenciesExtension on BuildContext {
  ExamDependencies get examDependencies =>
      ExamDependenciesProvider.of(this);
}
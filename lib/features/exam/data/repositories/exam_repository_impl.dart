import 'package:dio/dio.dart';
import 'package:academix/features/exam/domain/entities/exam_entity.dart';
import 'package:academix/features/exam/domain/repositories/exam_repository.dart';
import '../datasources/exam_remote_datasource.dart';

/// Implementación del repositorio de exámenes.
/// 
/// Responsabilidades:
/// - Delegar llamadas al [ExamRemoteDataSource].
/// - Traducir excepciones de infraestructura (DioException) a excepciones
///   del dominio ([PermissionDeniedException]) para que la capa de dominio
///   no dependa de Dio.
class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDataSource _remote;

  const ExamRepositoryImpl(this._remote);

  @override
  Future<List<ExamEntity>> getAvailableExams() {
    return _remote.getAvailableExams();
  }

  @override
  Future<ExamEntity> getExamById(int id) {
    return _remote.getExamById(id);
  }

  @override
  Future<ExamEntity> getExamCompleto(int id) {
    return _remote.getExamCompleto(id);
  }

  @override
  Future<List<CompletedExamEntity>> getCompletedExams() {
    return _remote.getCompletedExams();
  }

  @override
  Future<List<CompletedExamEntity>> getDetailedExams() async {
    try {
      return await _remote.getDetailedExams();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw const PermissionDeniedException(
          'Necesitas el beneficio DESGLOSE para ver el historial detallado.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ExamMisIntentosEntity> getMisIntentos(int idExamen) async {
    try {
      return await _remote.getMisIntentos(idExamen);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw const PermissionDeniedException(
          'Necesitas el beneficio HISTORIAL para ver todos los intentos.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<CompletedExamEntity> submitExam({
    required int idExamen,
    required Map<int, int> respuestas,
  }) {
    return _remote.submitExam(idExamen: idExamen, respuestas: respuestas);
  }
}
import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/exam/domain/repositories/exam_repository.dart';
import 'package:academix/features/exam/domain/usecases/get_completed_exams_usecase.dart';
import 'package:academix/features/exam/domain/usecases/get_mis_intentos_usecase.dart';
import 'package:academix/features/exam/domain/usecases/get_detailed_exams_premium_freemium_usecase.dart';
import 'package:academix/features/exam/data/models/exam_models.dart';

/// ViewModel del historial de exámenes.
///
/// Flujo:
///   1. Intenta obtener el historial completo con /detalles (premium).
///   2. Si recibe [PermissionDeniedException] (403), cae al flujo freemium
///      usando /realizados, que devuelve solo campos básicos.
///
/// La UI refleja automáticamente qué información hay disponible:
///   - Premium  → calificación, porcentaje, respuestas correctas, si aprobó.
///   - Freemium → solo título, calificación numérica y fecha.
class ExamHistoryViewModel extends ChangeNotifier {
  final GetCompletedExamsUseCase _getCompletedExams;
  final GetMisIntentosUseCase _getMisIntentos;
  final GetDetailedExamsPremiumFreemiumUseCase _getDetailedExams;

  final ValueNotifier<List<ExamHistoryGroupModel>> historyGroups =
      ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  /// true si el usuario tiene acceso premium (beneficio DESGLOSE).
  /// La UI puede leerlo para mostrar/ocultar elementos.
  final ValueNotifier<bool> isPremium = ValueNotifier(false);

  ExamHistoryViewModel({
    required GetCompletedExamsUseCase getCompletedExams,
    required GetMisIntentosUseCase getMisIntentos,
    required GetDetailedExamsPremiumFreemiumUseCase getDetailedExamsPremiumFreemium,
  })  : _getCompletedExams = getCompletedExams,
        _getMisIntentos = getMisIntentos,
        _getDetailedExams = getDetailedExamsPremiumFreemium;

  Future<void> loadHistory() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // ── Intento 1: flujo premium (/detalles) ───────────────────────────
      await _loadPremium();
    } on PermissionDeniedException {
      // ── Fallback: flujo freemium (/realizados) ─────────────────────────
      try {
        await _loadFreemium();
      } catch (_) {
        errorMessage.value = 'Error al cargar historial';
      }
    } catch (_) {
      errorMessage.value = 'Error al cargar historial';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Flujo premium ─────────────────────────────────────────────────────────
  // Usa GET /examen/usuario/{id}/detalles → devuelve porcentaje, respuestas
  // correctas, cantidad_preguntas y si aprobó.
  // Después intenta enriquecer con mis-intentos (HISTORIAL) para agrupar
  // múltiples intentos; si falla con 403 agrupa de todas formas con los datos
  // básicos disponibles.

  Future<void> _loadPremium() async {
    final detailedEntities = await _getDetailedExams(); // lanza 403 si no premium
    isPremium.value = true;

    final Map<int, List<dynamic>> grouped = {};
    for (final e in detailedEntities) {
      grouped.putIfAbsent(e.idExamen, () => []).add(e);
    }

    final List<ExamHistoryGroupModel> groups = [];

    for (final entry in grouped.entries) {
      final idExamen = entry.key;
      final entityList = entry.value;

      try {
        // Intenta obtener el listado ordenado de intentos (beneficio HISTORIAL)
        final misIntentos = await _getMisIntentos(idExamen);

        final intentoItems = misIntentos.intentos.map((i) {
          // Busca el detalle correspondiente para cruzar los campos premium
          final detail = entityList.firstWhere(
            (e) => e.idIntento == i.idIntento,
            orElse: () => entityList.first,
          );
          final score = detail.porcentaje != null && detail.porcentaje! > 0
              ? detail.porcentaje!.round()
              : (detail.calificacion * 10).round();

          return ExamIntentoItemModel(
            idIntento: i.idIntento,
            idExamen: idExamen,
            numero: i.numeroIntento,
            score: score,
            grade: detail.aprobo ? 'APROBADO' : 'REPROBADO',
            timeAgo: _formatDate(i.fecha),
            correctAnswers: detail.respuestasCorrectas,
            totalQuestions: detail.cantidadPreguntas,
            examTitle: misIntentos.tituloExamen,
          );
        }).toList();

        groups.add(ExamHistoryGroupModel(
          idExamen: idExamen,
          title: misIntentos.tituloExamen,
          intentos: intentoItems,
        ));
      } on PermissionDeniedException {
        // Tiene DESGLOSE pero no HISTORIAL: agrupa con un único intento por
        // entrada (no puede mostrar múltiples intentos expandibles).
        groups.add(_groupFromDetailedEntities(idExamen, entityList));
      }
    }

    historyGroups.value = groups;
  }

  // ── Flujo freemium ────────────────────────────────────────────────────────
  // Usa GET /examen/usuario/{id}/realizados → devuelve solo id_intento,
  // id_examen, titulo_examen, calificacion y fecha.
  // No hay porcentaje real ni respuestas correctas: muestra la calificación
  // numérica (sobre 10) como único indicador de rendimiento.

  Future<void> _loadFreemium() async {
    final completedEntities = await _getCompletedExams();
    isPremium.value = false;

    // /realizados no agrupa: cada fila es un intento individual
    final Map<int, List<dynamic>> grouped = {};
    for (final e in completedEntities) {
      grouped.putIfAbsent(e.idExamen, () => []).add(e);
    }

    final List<ExamHistoryGroupModel> groups = [];

    for (final entry in grouped.entries) {
      final idExamen = entry.key;
      final entityList = entry.value;

      // Para freemium mostramos un único intento por examen (el más reciente)
      // porque /realizados sí puede devolver varios pero no tenemos desglose.
      // La card no expande intentos múltiples en modo freemium.
      final entity = entityList.first;

      // calificacion de /realizados viene sobre 10; convertimos a porcentaje
      final score = (entity.calificacion * 10).round().clamp(0, 100);

      groups.add(ExamHistoryGroupModel(
        idExamen: idExamen,
        title: entity.examTitle,
        intentos: [
          ExamIntentoItemModel(
            idIntento: entity.idIntento,
            idExamen: entity.idExamen,
            numero: 1,
            score: score,
            // Freemium: no sabemos si aprobó (campo solo en /detalles)
            // Usamos el umbral estándar de 70%
            grade: score >= 70 ? 'APROBADO' : 'REPROBADO',
            timeAgo: entity.dateCompleted,
            // Freemium no tiene respuestas correctas ni total
            correctAnswers: 0,
            totalQuestions: 0,
            examTitle: entity.examTitle,
          ),
        ],
      ));
    }

    historyGroups.value = groups;
  }

  // ── Helper: agrupar desde entidades de /detalles sin HISTORIAL ───────────

  ExamHistoryGroupModel _groupFromDetailedEntities(
    int idExamen,
    List<dynamic> entityList,
  ) {
    final intentoItems = entityList.asMap().entries.map((e) {
      final idx = e.key + 1;
      final entity = e.value;
      final score = entity.porcentaje != null && entity.porcentaje! > 0
          ? entity.porcentaje!.round()
          : (entity.calificacion * 10).round();
      return ExamIntentoItemModel(
        idIntento: entity.idIntento,
        idExamen: idExamen,
        numero: idx,
        score: score,
        grade: entity.aprobo ? 'APROBADO' : 'REPROBADO',
        timeAgo: entity.dateCompleted,
        correctAnswers: entity.respuestasCorrectas,
        totalQuestions: entity.cantidadPreguntas,
        examTitle: entity.examTitle,
      );
    }).toList();

    return ExamHistoryGroupModel(
      idExamen: idExamen,
      title: entityList.first.examTitle,
      intentos: intentoItems,
    );
  }

  // ── Navegación ────────────────────────────────────────────────────────────

  void onTapIntento(
    BuildContext context,
    ExamHistoryGroupModel group,
    ExamIntentoItemModel intento,
  ) {
    final tempExam = ExamItemModel(
      id: group.idExamen.toString(),
      title: group.title,
      category: group.subtema ?? 'Examen completado',
      questions: intento.totalQuestions,
      durationMinutes: 0,
      difficulty: 'N/A',
    );

    AppNavigator.push(
      context,
      AppRoutes.examResult,
      arguments: {
        'exam': tempExam,
        'score': intento.score,
        'grade': intento.grade,
        'correctAnswers': intento.correctAnswers,
        'totalQuestions': intento.totalQuestions,
      },
    );
  }

  // ── Utils ─────────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 30) return 'Hace más de un mes';
    if (diff.inDays > 0) return 'Hace ${diff.inDays} días';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} horas';
    return 'Hoy';
  }

  @override
  void dispose() {
    historyGroups.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    isPremium.dispose();
    super.dispose();
  }
}
/*import 'package:flutter/material.dart';
import 'package:academix/features/library/domain/entities/ai_message_entity.dart';

/// Contract for AI chat functionality.
/// Implement a real version backed by an API and inject it via constructor.
abstract class AiService {
  Future<String> sendMessage({
    required String message,
    required String context,
  });
}

class AiViewModel {
  final AiService aiService;
  final bool isPremiumUser;

  AiViewModel({
    required this.aiService,
    required this.isPremiumUser,
  }) {
    isPremium.value = isPremiumUser;
  }

  final TextEditingController messageController = TextEditingController();
  final ValueNotifier<List<AiMessageEntity>> messages = ValueNotifier([]);
  final ValueNotifier<bool> isPremium = ValueNotifier(false);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String> contextText = ValueNotifier('');

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || !isPremium.value) return;

    isLoading.value = true;

    final userMessage = AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    messages.value = [...messages.value, userMessage];
    messageController.clear();

    try {
      final reply = await aiService.sendMessage(
        message: text,
        context: contextText.value,
      );

      final aiResponse = AiMessageEntity(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        message: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.value = [...messages.value, aiResponse];
    } catch (e) {
      final errorMsg = AiMessageEntity(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        message: 'Error al obtener respuesta. Intenta de nuevo.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.value = [...messages.value, errorMsg];
    } finally {
      isLoading.value = false;
    }
  }

  void setContext(String text) {
    contextText.value = text;
  }

  void dispose() {
    messageController.dispose();
    messages.dispose();
    isPremium.dispose();
    isLoading.dispose();
    contextText.dispose();
  }
}*/

import 'package:academix/core/network/dio_client.dart';
import 'package:academix/features/library/domain/entities/ai_message_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AiQuota {
  final String? membresia;
  final int? limiteDiario;
  final int usadasHoy;
  final int? restantes;
  final bool bloqueado;

  const AiQuota({
    required this.membresia,
    required this.limiteDiario,
    required this.usadasHoy,
    required this.restantes,
    required this.bloqueado,
  });

  factory AiQuota.fromJson(Map<String, dynamic> json) {
    return AiQuota(
      membresia: json['membresia']?.toString(),
      limiteDiario: _toInt(json['limite_diario']),
      usadasHoy: _toInt(json['usadas_hoy']) ?? 0,
      restantes: _toInt(json['restantes']),
      bloqueado: json['bloqueado'] == true,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  String get labelResumen {
    if (limiteDiario == null) {
      final nombre = (membresia == null || membresia!.isEmpty)
          ? 'Premium'
          : membresia!;
      return 'Membresía: $nombre · IA ilimitada';
    }
    return 'Consultas IA hoy: $usadasHoy/$limiteDiario · Restantes: ${restantes ?? 0}';
  }
}

class AiConsultResponse {
  final String explicacion;
  final List<String> sugerencias;
  final AiQuota? cuota;

  const AiConsultResponse({
    required this.explicacion,
    required this.sugerencias,
    required this.cuota,
  });
}

class AiQuotaExceededException implements Exception {
  final String message;
  final AiQuota cuota;

  const AiQuotaExceededException({
    required this.message,
    required this.cuota,
  });

  @override
  String toString() => message;
}

abstract class AiService {
  Future<AiQuota> getQuota();

  Future<AiConsultResponse> consult({
    required String selectedText,
    String? followUpQuestion,
  });
}

class HttpAiService implements AiService {
  @override
  Future<AiQuota> getQuota() async {
    final response = await DioClient.dio.get('/ia/cuota');
    return AiQuota.fromJson(_asMap(response.data));
  }

  @override
  Future<AiConsultResponse> consult({
    required String selectedText,
    String? followUpQuestion,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/ia/consultar',
        data: {
          'texto_seleccionado': selectedText,
          'pregunta_seguimiento':
              (followUpQuestion == null || followUpQuestion.trim().isEmpty)
                  ? null
                  : followUpQuestion.trim(),
        },
      );

      final data = _asMap(response.data);
      return AiConsultResponse(
        explicacion: (data['explicacion']?.toString().trim().isNotEmpty ?? false)
            ? data['explicacion'].toString().trim()
            : 'Sin respuesta.',
        sugerencias: _asStringList(data['sugerencias']),
        cuota: data['cuota'] is Map<String, dynamic>
            ? AiQuota.fromJson(data['cuota'] as Map<String, dynamic>)
            : data['cuota'] is Map
                ? AiQuota.fromJson(Map<String, dynamic>.from(data['cuota'] as Map))
                : null,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final detail = _extractDetailMap(e.response?.data);
        if (detail != null) {
          throw AiQuotaExceededException(
            message: detail['message']?.toString() ??
                'Agotaste tus consultas diarias de IA.',
            cuota: AiQuota.fromJson(detail),
          );
        }
        throw const AiQuotaExceededException(
          message: 'Agotaste tus consultas diarias de IA.',
          cuota: AiQuota(
            membresia: null,
            limiteDiario: 0,
            usadasHoy: 0,
            restantes: 0,
            bloqueado: true,
          ),
        );
      }

      final detail = e.response?.data;
      if (detail is Map && detail['detail'] != null) {
        throw Exception(detail['detail'].toString());
      }
      throw Exception('No se pudo consultar la IA en este momento.');
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<String> _asStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }

  Map<String, dynamic>? _extractDetailMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final detail = body['detail'];
      if (detail is Map<String, dynamic>) return detail;
      if (detail is Map) return Map<String, dynamic>.from(detail);
      return body;
    }
    if (body is Map) return Map<String, dynamic>.from(body);
    return null;
  }
}

class AiViewModel {
  final AiService aiService;

  AiViewModel({AiService? aiService}) : aiService = aiService ?? HttpAiService();

  final TextEditingController messageController = TextEditingController();
  final ValueNotifier<List<AiMessageEntity>> messages = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String> contextText = ValueNotifier('');
  final ValueNotifier<AiQuota?> quota = ValueNotifier(null);
  final ValueNotifier<List<String>> suggestions = ValueNotifier([]);
  final ValueNotifier<String?> bannerMessage = ValueNotifier(null);

  Future<void> initialize({String? initialContext}) async {
    setContext(initialContext ?? '');
    await loadQuota();
  }

  Future<void> loadQuota() async {
    try {
      quota.value = await aiService.getQuota();
      bannerMessage.value = null;
    } catch (_) {
      bannerMessage.value = 'No se pudo cargar la cuota de IA.';
    }
  }

  void setContext(String text) {
    contextText.value = text.trim();
  }

  Future<void> askForSelectedText() async {
    if (contextText.value.trim().isEmpty) return;
    await _consult(followUpQuestion: null, addUserBubble: false);
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isBlocked) return;

    final userMessage = AiMessageEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    messages.value = [...messages.value, userMessage];
    messageController.clear();

    await _consult(followUpQuestion: text, addUserBubble: false);
  }

  Future<void> sendSuggestion(String suggestion) async {
    if (suggestion.trim().isEmpty || isBlocked) return;

    final userMessage = AiMessageEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: suggestion,
      isUser: true,
      timestamp: DateTime.now(),
    );

    messages.value = [...messages.value, userMessage];
    await _consult(followUpQuestion: suggestion, addUserBubble: false);
  }

  Future<void> _consult({
    required String? followUpQuestion,
    required bool addUserBubble,
  }) async {
    if (isBlocked) return;

    isLoading.value = true;
    bannerMessage.value = null;

    try {
      final response = await aiService.consult(
        selectedText: contextText.value,
        followUpQuestion: followUpQuestion,
      );

      if (response.cuota != null) {
        quota.value = response.cuota;
      }
      suggestions.value = response.sugerencias;

      final aiResponse = AiMessageEntity(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        message: response.explicacion,
        isUser: false,
        timestamp: DateTime.now(),
      );

      messages.value = [...messages.value, aiResponse];
    } on AiQuotaExceededException catch (e) {
      quota.value = e.cuota;
      bannerMessage.value = e.message;
    } catch (e) {
      bannerMessage.value = e.toString().replaceFirst('Exception: ', '');
      final aiError = AiMessageEntity(
        id: (DateTime.now().microsecondsSinceEpoch + 2).toString(),
        message: 'No se pudo consultar la IA en este momento.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.value = [...messages.value, aiError];
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasContext => contextText.value.trim().isNotEmpty;
  bool get isBlocked => quota.value?.bloqueado == true;
  bool get hasInitialAnswer => messages.value.any((m) => !m.isUser);

  void dispose() {
    messageController.dispose();
    messages.dispose();
    isLoading.dispose();
    contextText.dispose();
    quota.dispose();
    suggestions.dispose();
    bannerMessage.dispose();
  }
}

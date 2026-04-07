import 'package:flutter/material.dart';
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
}
import 'package:flutter/material.dart';
import '../../domain/entities/ai_message_entity.dart';

class AiViewModel extends ChangeNotifier {
  final TextEditingController messageController = TextEditingController();
  final ValueNotifier<List<AiMessageEntity>> messages = ValueNotifier([]);
  final ValueNotifier<bool> isPremium = ValueNotifier(false);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String> contextText = ValueNotifier('');

  AiViewModel() {
    _loadHistory();
    isPremium.value = false; // Cambiar el false
  }

  void _loadHistory() {
    // Mock chat history
    messages.value = [
      AiMessageEntity(id: '1', message: 'Selecciona texto para explicación IA', isUser: false, timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      AiMessageEntity(id: '2', message: 'Texto seleccionado: E=mc²', isUser: true, timestamp: DateTime.now().subtract(const Duration(minutes: 4))),
    ];
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty || !isPremium.value) return;
    isLoading.value = true;

    final userMessage = AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: messageController.text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    messages.value = [...messages.value, userMessage];
    messageController.clear();

    // Mock AI response
    await Future.delayed(const Duration(seconds: 1));
    final aiResponse = AiMessageEntity(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      message: 'Explicación IA sobre "${contextText.value}": Esta es una explicación generada por IA sobre el contenido seleccionado...',
      isUser: false,
      timestamp: DateTime.now(),
    );
    messages.value = [...messages.value, aiResponse];

    isLoading.value = false;
    notifyListeners();
  }

  bool get isPremiumUser => true; // Mock premium check

  void setContext(String text) {
    contextText.value = text;
  }

  @override
  void dispose() {
    messageController.dispose();
    messages.dispose();
    isPremium.dispose();
    isLoading.dispose();
    contextText.dispose();
    super.dispose();
  }
}

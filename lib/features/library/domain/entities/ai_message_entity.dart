class AiMessageEntity {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const AiMessageEntity({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

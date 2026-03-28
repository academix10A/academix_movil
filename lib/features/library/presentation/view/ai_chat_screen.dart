import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/library/presentation/viewmodel/ai_viewmodel.dart';
import 'package:academix/features/library/domain/entities/ai_message_entity.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late final AiViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = AiViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.smart_toy, color: AppColors.primary, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Academix IA",
                        style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                      ),
                      ValueListenableBuilder(
                        valueListenable: vm.isPremium,
                        builder: (context, isPremium, _) => Text(
                          isPremium ? "Premium Activado" : "Requiere Premium",
                          style: AppTextStyles.caption.copyWith(
                            color: isPremium ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: vm.contextText,
              builder: (context, contextText, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contexto:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                      Text(contextText.isEmpty ? 'Selecciona texto en contenido' : contextText),
                    ],
                  ),
                ),
              ),
            ),
            // Chat messages
            Expanded(
              child: ValueListenableBuilder<List<AiMessageEntity>>(
                valueListenable: vm.messages,
                builder: (context, messages, _) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Empieza seleccionando texto en cualquier recurso',
                        style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg.isUser;
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.primary : AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Column(
                            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.message,
                                style: AppTextStyles.body.copyWith(
                                  color: isUser ? AppColors.background : AppColors.text,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _formatTime(msg.timestamp),
                                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Input
            ValueListenableBuilder<bool>(
              valueListenable: vm.isPremium,
              builder: (context, isPremium, _) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.border.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: vm.messageController,
                          enabled: isPremium,
                          decoration: InputDecoration(
                            hintText: isPremium ? 'Pregunta sobre el contexto...' : 'Premium requerido',
                            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.backgroundCard,
                            prefixIcon: ValueListenableBuilder<bool>(
                              valueListenable: vm.isLoading,
                              builder: (context, loading, _) => loading 
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                                : Icon(Icons.send, color: AppColors.textMuted),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.full), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          ),
                          onSubmitted: isPremium ? (_) => vm.sendMessage() : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

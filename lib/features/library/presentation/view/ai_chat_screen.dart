import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/features/library/domain/entities/ai_message_entity.dart';
import 'package:academix/features/library/presentation/viewmodel/ai_viewmodel.dart';
import 'package:flutter/material.dart';

class AiChatScreen extends StatefulWidget {
  final String? initialContext;

  const AiChatScreen({
    super.key,
    this.initialContext,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late final AiViewModel vm;
  late final ScrollController _scrollController;
  late final Listenable _merged;

  @override
  void initState() {
    super.initState();
    vm = AiViewModel();
    _scrollController = ScrollController();
    _merged = Listenable.merge([
      vm.messages,
      vm.isLoading,
      vm.contextText,
      vm.quota,
      vm.suggestions,
      vm.bannerMessage,
    ]);

    vm.initialize(initialContext: widget.initialContext);
    vm.messages.addListener(_scrollToBottomSoon);
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    vm.messages.removeListener(_scrollToBottomSoon);
    _scrollController.dispose();
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _merged,
          builder: (context, _) {
            final quota = vm.quota.value;
            final messages = vm.messages.value;
            final loading = vm.isLoading.value;
            final contextText = vm.contextText.value;
            final blocked = vm.isBlocked;
            final suggestions = vm.suggestions.value;
            final banner = vm.bannerMessage.value;
            final canSend = !loading && !blocked && contextText.isNotEmpty;

            return Column(
              children: [
                _buildHeader(quota),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      _buildContextCard(contextText, blocked, loading),
                      if (banner != null && banner.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildBanner(banner, blocked),
                      ],
                      if (contextText.isNotEmpty && !vm.hasInitialAnswer) ...[
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: canSend ? vm.askForSelectedText : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.background,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                            ),
                            icon: loading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.background,
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome),
                            label: Text(
                              blocked
                                  ? 'Consultas agotadas'
                                  : loading
                                      ? 'Consultando…'
                                      : 'Preguntar a la IA',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.background,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      if (messages.isEmpty)
                        _buildEmptyState(contextText.isNotEmpty)
                      else
                        ...messages.map(_buildMessageBubble),
                      if (suggestions.isNotEmpty && messages.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Profundiza:',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: suggestions
                              .map(
                                (s) => ActionChip(
                                  label: Text(s),
                                  onPressed: canSend ? () => vm.sendSuggestion(s) : null,
                                  backgroundColor: AppColors.backgroundCard,
                                  side: const BorderSide(color: AppColors.border),
                                  labelStyle: AppTextStyles.caption.copyWith(
                                    color: AppColors.text,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AiQuota? quota) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academix IA',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quota?.labelResumen ?? 'Cargando cuota de IA…',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContextCard(String contextText, bool blocked, bool loading) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Texto seleccionado',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            contextText.isEmpty
                ? 'Abre un PDF, selecciona un fragmento y luego pregúntale a la IA.'
                : contextText,
            style: AppTextStyles.bodySmall.copyWith(
              color: contextText.isEmpty ? AppColors.textMuted : AppColors.text,
            ),
          ),
          if (blocked) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ya agotaste tus consultas diarias de IA.',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ] else if (loading) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Consultando…',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBanner(String message, bool isError) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.error.withOpacity(0.12)
            : AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isError
              ? AppColors.error.withOpacity(0.35)
              : AppColors.accent.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: isError ? AppColors.error : AppColors.accent,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool hasContext) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.smart_toy_outlined,
              color: AppColors.primary, size: 42),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasContext
                ? 'Toca el botón para obtener una explicación del texto seleccionado.'
                : 'Selecciona texto dentro del PDF para comenzar.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AiMessageEntity msg) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.message,
              style: AppTextStyles.bodySmall.copyWith(
                color: isUser ? AppColors.background : AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatTime(msg.timestamp),
              style: AppTextStyles.caption.copyWith(
                color: isUser
                    ? AppColors.background.withOpacity(0.75)
                    : AppColors.textMuted,
              ),
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

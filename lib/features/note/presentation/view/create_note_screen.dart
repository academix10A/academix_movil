import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/note/presentation/di/note_di.dart';
import 'package:academix/features/note/presentation/viewmodel/create_note_viewmodel.dart';
import '../widgets/select_resource_bottomsheet.dart';

class CreateNoteScreen extends StatefulWidget {
  final int? preselectedResourceId;
  final String? preselectedResourceTitle;

  const CreateNoteScreen({
    super.key,
    this.preselectedResourceId,
    this.preselectedResourceTitle,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  // ViewModel inyectado desde DI, no instanciado a mano.
  late final CreateNoteViewModel vm;

  bool get _hasLockedResource => widget.preselectedResourceId != null;

  @override
  void initState() {
    super.initState();
    vm = NoteDI.createNoteViewModel();
    if (_hasLockedResource) {
      vm.setSelectedResource(
        widget.preselectedResourceId,
        widget.preselectedResourceTitle,
      );
    }
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Nueva Nota",
          style: AppTextStyles.h1.copyWith(color: AppColors.text),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: vm.isLoading,
            builder: (context, loading, _) => loading
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.check, color: AppColors.primary),
                    onPressed: () async {
                      final success = await vm.saveNote();
                      if (success && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              TextField(
                controller: vm.titleController,
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.text,
                  fontSize: 24,
                ),
                decoration: InputDecoration(
                  hintText: "Título de la nota",
                  hintStyle: AppTextStyles.h1.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 24,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Toggle pública
              ListenableBuilder(
                listenable: vm,
                builder: (context, _) => Row(
                  children: [
                    Switch(
                      value: vm.isPublic,
                      onChanged: (_) => vm.togglePublic(),
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nota pública",
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          vm.isPublic
                              ? "Otros usuarios podrán verla"
                              : "Solo tú podrás verla",
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Recurso
              Text(
                _hasLockedResource ? "Recurso vinculado" : "Recurso (opcional)",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              if (_hasLockedResource)
                _LockedResourceBadge(
                    title: widget.preselectedResourceTitle ?? '')
              else
                ValueListenableBuilder<bool>(
                  valueListenable: vm.hasResource,
                  builder: (context, hasResource, _) =>
                      ValueListenableBuilder<String?>(
                    valueListenable: vm.selectedResourceTitle,
                    builder: (context, title, _) {
                      if (!hasResource) {
                        return OutlinedButton.icon(
                          onPressed: () => SelectResourceBottomSheet.show(
                            context,
                            onSelected: (id, resourceTitle) =>
                                vm.setSelectedResource(id, resourceTitle),
                          ),
                          icon: Icon(Icons.menu_book,
                              size: 20, color: AppColors.primary),
                          label: const Text('Seleccionar recurso'),
                          style: OutlinedButton.styleFrom(
                            side:
                                BorderSide(color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                          ),
                        );
                      }
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              border:
                                  Border.all(color: AppColors.accent, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.menu_book,
                                    size: 16, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    title ?? '',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          IconButton(
                            onPressed: () => vm.setSelectedResource(null, null),
                            icon: Icon(Icons.close,
                                size: 16, color: AppColors.textMuted),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              const SizedBox(height: AppSpacing.lg),

              // Etiquetas
              Text(
                "Etiquetas (opcional)",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              _TagInput(
                onAdd: vm.addTag,
                tags: vm.tags,
                onRemove: vm.removeTag,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Contenido
              Text(
                "Contenido",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 300),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: TextField(
                  controller: vm.contentController,
                  maxLines: null,
                  minLines: 10,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.text, height: 1.6),
                  decoration: InputDecoration(
                    hintText: "Escribe tu nota aquí...",
                    hintStyle:
                        AppTextStyles.body.copyWith(color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),

              ValueListenableBuilder<String?>(
                valueListenable: vm.errorMessage,
                builder: (context, error, _) {
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Text(
                      error,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _TagInput extends StatefulWidget {
  final void Function(String) onAdd;
  final ValueNotifier<List<String>> tags;
  final void Function(String) onRemove;

  const _TagInput({
    required this.onAdd,
    required this.tags,
    required this.onRemove,
  });

  @override
  State<_TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<_TagInput> {
  final _controller = TextEditingController();

  void _submit() {
    widget.onAdd(_controller.text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: "Agregar etiqueta (ej. matemáticas)",
                  hintStyle: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.add, size: 20),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ValueListenableBuilder<List<String>>(
          valueListenable: widget.tags,
          builder: (context, tags, _) => Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: tags
                .map(
                  (tag) => Chip(
                    label: Text(
                      tag,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    deleteIcon: const Icon(Icons.close,
                        size: 16, color: Colors.white),
                    onDeleted: () => widget.onRemove(tag),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _LockedResourceBadge extends StatelessWidget {
  final String title;
  const _LockedResourceBadge({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.lock_rounded,
              size: 14, color: AppColors.primary.withOpacity(0.7)),
        ],
      ),
    );
  }
}
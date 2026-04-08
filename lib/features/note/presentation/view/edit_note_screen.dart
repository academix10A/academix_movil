import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/note/domain/usecases/note_usecases.dart';
import 'package:academix/features/note/presentation/di/note_di.dart';
import 'package:academix/features/note/presentation/viewmodel/notes_viewmodel.dart';

/// ViewModel mínimo para edición.
/// Sólo necesita UpdateNoteUseCase — no toda la suite de NotesViewModel.
class _EditNoteViewModel extends ChangeNotifier {
  final UpdateNoteUseCase _updateNoteUseCase;

  _EditNoteViewModel({required UpdateNoteUseCase updateNoteUseCase})
      : _updateNoteUseCase = updateNoteUseCase;

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  bool isPublic = false;

  void togglePublic() {
    isPublic = !isPublic;
    notifyListeners();
  }

  Future<bool> save({
    required int id,
    required String titulo,
    required String contenido,
  }) async {
    errorMessage.value = null;
    isLoading.value = true;
    try {
      await _updateNoteUseCase(
        id: id,
        titulo: titulo,
        contenido: contenido,
        esCompartida: isPublic,
      );
      return true;
    } on ArgumentError catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Error al guardar: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    super.dispose();
  }
}

class EditNoteScreen extends StatefulWidget {
  final NoteItem note;

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late final _EditNoteViewModel vm;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    vm = _EditNoteViewModel(updateNoteUseCase: NoteDI.updateNoteUseCase);
    vm.isPublic = widget.note.isShared;

    _titleController = TextEditingController(text: widget.note.title);
    // FIX: usamos `content` (contenido completo), no `preview` (resumen truncado)
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    vm.dispose();
    _titleController.dispose();
    _contentController.dispose();
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
          "Editar Nota",
          style: AppTextStyles.h1.copyWith(color: AppColors.text),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: vm.isLoading,
            builder: (context, loading, _) => loading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.check, color: AppColors.primary),
                    onPressed: () async {
                      final success = await vm.save(
                        id: widget.note.idNota!,
                        titulo: _titleController.text,
                        contenido: _contentController.text,
                      );
                      if (success && context.mounted) {
                        Navigator.pop(context, true); // true = hubo cambios
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
                controller: _titleController,
                style:
                    AppTextStyles.h1.copyWith(color: AppColors.text, fontSize: 24),
                decoration: InputDecoration(
                  hintText: "Título de la nota",
                  hintStyle: AppTextStyles.h1
                      .copyWith(color: AppColors.textMuted, fontSize: 24),
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
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _contentController,
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
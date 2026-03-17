import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/note/domain/entities/note_entity.dart';
import 'package:academix/features/note/presentation/viewmodel/create_note_viewmodel.dart'; // Reuse for edit
import 'package:academix/features/note/presentation/viewmodel/notes_viewmodel.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteItem note;

  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late CreateNoteViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = CreateNoteViewModel()
      ..titleController.text = widget.note.title
      ..contentController.text = widget.note.preview
      ..tags.value = widget.note.tags
      ..isPublic = widget.note.isShared;
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
          "Editar Nota",
          style: AppTextStyles.h1.copyWith(color: AppColors.text),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: ValueNotifier(vm.isLoading),
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
                      if (success) {
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
              Row(
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
                        vm.isPublic ? "Otros usuarios podrán verla" : "Solo tú podrás verla",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Rest same as CreateNoteScreen
              Text(
                "Etiquetas",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Tag input same
              // ... (copy from CreateNoteScreen)

              // Contenido same
              // ... 

              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Text(
                    vm.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}


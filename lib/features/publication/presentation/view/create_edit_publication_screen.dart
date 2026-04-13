import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/features/publication/presentation/viewmodel/create_edit_publication_viewmodel.dart';
import 'package:academix/features/publication/presentation/viewmodel/publication_di.dart';
import '../../domain/entities/publication_entity.dart';

class CreateEditPublicationScreen extends StatefulWidget {
  final bool isEdit;
  final PublicationEntity? publication;

  const CreateEditPublicationScreen({
    super.key,
    required this.isEdit,
    this.publication,
  });

  @override
  State<CreateEditPublicationScreen> createState() =>
      _CreateEditPublicationScreenState();
}

class _CreateEditPublicationScreenState
    extends State<CreateEditPublicationScreen> {
  late CreateEditPublicationViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = PublicationDI.createEditPublicationViewModel();
    if (widget.isEdit && widget.publication != null) {
      _vm.loadPublication(widget.publication!);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    bool success;
    if (widget.isEdit && widget.publication != null) {
      success = await _vm.updatePublication(widget.publication!.id);
    } else {
      success = await _vm.createPublication();
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context, rootNavigator: true).pop(true);
    }
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
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
        ),
        title: Text(
          widget.isEdit ? 'Editar Publicación' : 'Nueva Publicación',
          style: AppTextStyles.h1.copyWith(color: AppColors.text),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _vm.isLoading,
            builder: (context, loading, _) => loading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
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
                    icon: const Icon(Icons.check, color: AppColors.primary),
                    onPressed: _submit,
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
              TextField(
                controller: _vm.tituloController,
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.text,
                  fontSize: 24,
                ),
                decoration: InputDecoration(
                  hintText: "Título de la publicación *",
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

              const _SectionLabel(label: "Descripción (opcional)"),
              const SizedBox(height: AppSpacing.sm),
              _StyledTextField(
                controller: _vm.descripcionController,
                hintText: "Agrega una descripción corta...",
                maxLines: 3,
                minLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel(label: "Etiquetas (separadas por comas)"),
              const SizedBox(height: AppSpacing.sm),
              _StyledTextField(
                controller: _vm.etiquetasController,
                hintText: "ej. matemáticas, cálculo, álgebra",
                maxLines: 1,
              ),
              const SizedBox(height: AppSpacing.lg),

              const _SectionLabel(label: "Texto *"),
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
                  controller: _vm.textoController,
                  maxLines: null,
                  minLines: 10,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.text,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: "Escribe tu publicación aquí...",
                    hintStyle: AppTextStyles.body
                        .copyWith(color: AppColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),

              ValueListenableBuilder<String?>(
                valueListenable: _vm.error,
                builder: (context, errorMsg, _) {
                  if (errorMsg == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Text(
                      errorMsg,
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

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final int minLines;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: minLines,
        style: AppTextStyles.body.copyWith(color: AppColors.text),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle:
              AppTextStyles.body.copyWith(color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }
}
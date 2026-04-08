import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/note/presentation/di/note_di.dart';
import 'package:academix/features/note/presentation/viewmodel/notes_viewmodel.dart';
import 'package:academix/features/note/presentation/widgets/note_card.dart';
import 'package:academix/features/note/presentation/view/create_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // El ViewModel se obtiene desde DI, nunca se instancia directamente en la View.
  late final NotesViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = NoteDI.notesViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  void _openCreateNote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
    ).then((_) => vm.loadNotes()); // refresca al volver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ACADEMIX",
                    style: AppTextStyles.display.copyWith(
                      fontSize: 28,
                      letterSpacing: 1.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Mis notas",
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Organiza tu conocimiento",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Barra de búsqueda
                  TextField(
                    controller: vm.searchController,
                    onSubmitted: vm.onSearch,
                    style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                    decoration: InputDecoration(
                      hintText: "Buscar en tus notas...",
                      hintStyle: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.backgroundCard,
                      prefixIcon:
                          Icon(Icons.search, color: AppColors.textMuted),
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
                  const SizedBox(height: AppSpacing.md),

                  // Filtros
                  ValueListenableBuilder<NoteFilter>(
                    valueListenable: vm.selectedFilter,
                    builder: (context, selected, _) {
                      return Row(
                        children: NoteFilter.values.map((filter) {
                          final isSelected = selected == filter;
                          return Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.sm),
                            child: GestureDetector(
                              onTap: () => vm.selectFilter(filter),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  filter.label,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isSelected
                                        ? AppColors.background
                                        : AppColors.text,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Lista de notas
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: vm.isLoading,
                builder: (context, loading, _) {
                  if (loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ValueListenableBuilder<List<NoteItem>>(
                    valueListenable: vm.filteredNotes,
                    builder: (context, notes, _) {
                      if (notes.isEmpty) {
                        return Center(
                          child: Text(
                            "No se encontraron notas",
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textMuted),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        itemCount: notes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return NoteCard(
                            note: notes[index],
                            onTap: () =>
                                vm.onNoteTap(context, notes[index]),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateNote,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
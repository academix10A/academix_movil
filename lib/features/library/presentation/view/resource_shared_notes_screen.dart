import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/presentation/viewmodel/resource_shared_notes_viewmodel.dart';
import 'package:academix/features/note/domain/entities/note_entity.dart';

class ResourceSharedNotesScreen extends StatefulWidget {
  final int idRecurso;
  final String resourceTitle;

  const ResourceSharedNotesScreen({
    super.key,
    required this.idRecurso,
    required this.resourceTitle,
  });

  @override
  State<ResourceSharedNotesScreen> createState() => _ResourceSharedNotesScreenState();
}

class _ResourceSharedNotesScreenState extends State<ResourceSharedNotesScreen> {
  final ResourceSharedNotesViewModel vm = ResourceSharedNotesViewModel();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    vm.loadSharedNotes(widget.idRecurso);
  }

  @override
  void dispose() {
    vm.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => AppNavigator.pop(context),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: AppTextStyles.body.copyWith(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'Buscar en notas...',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
                autofocus: true,
                onSubmitted: (_) => vm.updateSearchQuery(_searchController.text),
              )
            : Text(
                'Notas compartidas - ${widget.resourceTitle}',
                style: AppTextStyles.h1.copyWith(color: AppColors.text),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() => _isSearching = true);
              },
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isSearching = false);
                _searchController.clear();
                vm.updateSearchQuery('');
              },
            ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: vm.isLoading,
        builder: (context, loading, _) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<String?>(
            valueListenable: vm.errorMessage,
            builder: (context, error, _) {
              if (error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: AppColors.textMuted),
                      const SizedBox(height: AppSpacing.md),
                      Text('Error: $error', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                );
              }

              return ValueListenableBuilder<List<NoteEntity>>(
                valueListenable: vm.filteredNotes,
                builder: (context, filteredNotes, _) {
                  if (filteredNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notes_outlined, size: 80, color: AppColors.textMuted),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No hay notas compartidas',
                            style: AppTextStyles.h2.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Sé el primero en compartir tus notas sobre este recurso.',
                            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        color: AppColors.backgroundCard,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                          title: Text(
                            note.titulo,
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                note.contenido.length > 100
                                    ? '${note.contenido.substring(0, 100)}...'
                                    : note.contenido,
                                style: AppTextStyles.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                note.timeAgo,
                                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

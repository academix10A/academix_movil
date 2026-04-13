// publication/presentation/view/publications_screen.dart
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/features/publication/presentation/viewmodel/publication_di.dart';
import 'package:academix/features/publication/presentation/viewmodel/publications_viewmodel.dart';
import 'package:academix/features/publication/presentation/widgets/publication_card.dart';
import '../../domain/entities/publication_entity.dart';
import 'create_edit_publication_screen.dart';

class PublicationsScreen extends StatefulWidget {
  const PublicationsScreen({super.key});

  @override
  State<PublicationsScreen> createState() => _PublicationsScreenState();
}

class _PublicationsScreenState extends State<PublicationsScreen> {
  late final PublicationsViewModel vm;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    vm = PublicationDI.publicationsViewModel();
    vm.loadPublications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    vm.dispose();
    super.dispose();
  }

  // ── Navegación al detalle ─────────────────────────────────────────────────

  void _openDetail(PublicationEntity pub) async {
    await AppNavigator.push(
      context,
      AppRoutes.publicationDetail,
      arguments: pub,
    );
    // Siempre recarga al volver: el detalle pudo haber editado o eliminado
    vm.loadPublications();
  }

  void _showCreatePublication() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEditPublicationScreen(isEdit: false),
      ),
    );
    if (result == true) vm.loadPublications();
  }

  void _showEditPublication(PublicationEntity pub) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEditPublicationScreen(isEdit: true, publication: pub),
      ),
    );
    if (result == true) vm.loadPublications();
  }

  Future<void> _confirmDelete(PublicationEntity pub) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Eliminar publicación', style: AppTextStyles.h2.copyWith(color: AppColors.text)),
        content: Text(
          '¿Seguro que deseas eliminar "${pub.titulo}"? Esta acción no se puede deshacer.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) await vm.deletePublication(pub.id);
  }

  // // ── Flujo crear ───────────────────────────────────────────────────────────

  // void _showCreatePublication() async {
  //   await AppNavigator.push(context, AppRoutes.createNote);
  //   // Usa la ruta que tengas registrada para crear publicación.
  //   // Si tienes una ruta específica, cámbiala aquí.
  //   vm.loadPublications();
  // }

  // // ── Flujo editar (desde el menú de la card) ───────────────────────────────

  // void _showEditPublication(PublicationEntity pub) async {
  //   await AppNavigator.push(
  //     context,
  //     AppRoutes.publicationDetail,
  //     arguments: pub,
  //   );
  //   vm.loadPublications();
  // }

  // // ── Confirmar eliminar (desde el menú de la card) ─────────────────────────

  // Future<void> _confirmDelete(PublicationEntity pub) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       backgroundColor: AppColors.backgroundCard,
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(AppRadius.lg)),
  //       title: Text('Eliminar publicación',
  //           style: AppTextStyles.h2.copyWith(color: AppColors.text)),
  //       content: Text(
  //         '¿Seguro que deseas eliminar "${pub.titulo}"? Esta acción no se puede deshacer.',
  //         style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: Text('Cancelar',
  //               style: TextStyle(color: AppColors.textMuted)),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, true),
  //           child:
  //               Text('Eliminar', style: TextStyle(color: AppColors.error)),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (confirmed == true) await vm.deletePublication(pub.id);
  // }

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
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ACADEMIX",
                      style: AppTextStyles.display.copyWith(
                          fontSize: 28,
                          letterSpacing: 1.5,
                          color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.lg),
                  Text("Mis publicaciones",
                      style: AppTextStyles.h1
                          .copyWith(color: AppColors.primary, fontSize: 28)),
                  const SizedBox(height: AppSpacing.xs),
                  Text("Comparte tu conocimiento",
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _searchController,
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.textMuted),
                    decoration: InputDecoration(
                      hintText: "Buscar publicaciones...",
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
                          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: vm.isLoading,
                builder: (context, loading, _) {
                  if (loading && vm.publications.value.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: vm.loadPublications,
                    color: AppColors.primary,
                    child: ValueListenableBuilder<String?>(
                      valueListenable: vm.error,
                      builder: (context, errorMsg, _) {
                        if (errorMsg != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 64, color: AppColors.textMuted),
                                const SizedBox(height: AppSpacing.md),
                                Text('Error: $errorMsg',
                                    style: AppTextStyles.body.copyWith(
                                        color: AppColors.textMuted)),
                                const SizedBox(height: AppSpacing.md),
                                ElevatedButton(
                                    onPressed: vm.loadPublications,
                                    child: const Text('Reintentar')),
                              ],
                            ),
                          );
                        }
                        return ValueListenableBuilder<List<PublicationEntity>>(
                          valueListenable: vm.publications,
                          builder: (context, publications, _) {
                            if (publications.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.article_outlined,
                                        size: 64, color: AppColors.textMuted),
                                    const SizedBox(height: AppSpacing.md),
                                    Text('No tienes publicaciones',
                                        style: AppTextStyles.h2.copyWith(
                                            color: AppColors.textMuted)),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Crea tu primera publicación\npara compartir conocimiento',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.md),
                              itemCount: publications.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final pub = publications[index];
                                return PublicationCard(
                                  publication: pub,
                                  onTap: () => _openDetail(pub),
                                  onEdit: () => _showEditPublication(pub),
                                  onDelete: () => _confirmDelete(pub),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePublication,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/network/dio_client.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/search_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/library_di.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';
import 'package:academix/features/library/presentation/widgets/library_resource_card.dart';
import 'package:academix/features/library/presentation/widgets/search_results_list.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryViewModel? _vm;
  late final SearchViewModel _searchVm;

  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchVm = LibraryDI.searchViewModel();
    _initViewModel();
  }

  Future<void> _initViewModel() async {
    try {
      final response = await DioClient.dio.get('/usuarios/me');
      final int idUsuario = response.data['id_usuario'] as int;
      if (!mounted) return;
      setState(() {
        _vm = LibraryDI.libraryViewModel(idUsuario: idUsuario);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _vm = LibraryDI.libraryViewModel(idUsuario: 1);
      });
    }
  }

  void _activateSearch() {
    setState(() => _isSearching = true);
    // pequeño delay para que el widget esté montado antes de pedir focus
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _deactivateSearch() {
    _searchFocusNode.unfocus();
    _searchVm.searchController.clear();
    _searchVm.onSearch('');
    setState(() => _isSearching = false);
  }

  @override
  void dispose() {
    _searchVm.dispose();
    _vm?.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header animado ──────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _isSearching
                  ? _SearchHeader(
                      key: const ValueKey('search'),
                      searchVm: _searchVm,
                      focusNode: _searchFocusNode,
                      onBack: _deactivateSearch,
                    )
                  : _LibraryHeader(
                      key: const ValueKey('library'),
                      vm: vm,
                      onSearchTap: _activateSearch,
                    ),
            ),

            // ── Contenido principal ─────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _isSearching
                    ? SearchResultsList(
                        key: const ValueKey('search-results'),
                        searchVm: _searchVm,
                      )
                    : _LibraryContent(
                        key: const ValueKey('library-content'),
                        vm: vm,
                        onRefresh: () async => _vm?.loadResources(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header: estado biblioteca ─────────────────────────────────────────────────

class _LibraryHeader extends StatelessWidget {
  final LibraryViewModel? vm;
  final VoidCallback onSearchTap;

  const _LibraryHeader({super.key, required this.vm, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ACADEMIX",
            style: AppTextStyles.display.copyWith(
              fontSize: 26,
              letterSpacing: 2.0,
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            "Biblioteca",
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "Explora recursos educativos",
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Barra de búsqueda (solo decorativa, activa el modo search al tap)
          GestureDetector(
            onTap: onSearchTap,
            child: AbsorbPointer(
              child: TextField(
                style: AppTextStyles.body.copyWith(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: "Buscar recursos, notas, publicaciones...",
                  hintStyle:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.backgroundCard,
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Chips de categorías
          if (vm != null)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValueListenableBuilder<List<String>>(
                valueListenable: vm!.categories,
                builder: (context, categories, _) {
                  return ValueListenableBuilder<String>(
                    valueListenable: vm!.selectedCategory,
                    builder: (context, selected, _) {
                      return Row(
                        children: categories.map((category) {
                          final isSelected = selected == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: GestureDetector(
                              onTap: () => vm!.selectCategory(category),
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
                                  category,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isSelected
                                        ? AppColors.background
                                        : AppColors.text,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Header: estado búsqueda ───────────────────────────────────────────────────

class _SearchHeader extends StatelessWidget {
  final SearchViewModel searchVm;
  final FocusNode focusNode;
  final VoidCallback onBack;

  const _SearchHeader({
    super.key,
    required this.searchVm,
    required this.focusNode,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila: botón atrás + barra de búsqueda
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.text),
                onPressed: onBack,
              ),
              Expanded(
                child: TextField(
                  controller: searchVm.searchController,
                  focusNode: focusNode,
                  onChanged: searchVm.onSearch,
                  autofocus: false,
                  style: AppTextStyles.body.copyWith(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'Buscar temas, títulos, etiquetas...',
                    hintStyle: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.backgroundCard,
                    prefixIcon:
                        Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: () {
                        searchVm.searchController.clear();
                        searchVm.onSearch('');
                      },
                    ),
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
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Tabs de tipo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: ValueListenableBuilder<String>(
              valueListenable: searchVm.selectedTabNotifier,
              builder: (context, selectedTab, _) {
                return Row(
                  children: searchVm.tabs.map((tab) {
                    final isSelected = selectedTab == tab;
                    return GestureDetector(
                      onTap: () => searchVm.selectTab(tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
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
                          tab,
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
                    );
                  }).toList(),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Contenido: lista de recursos de la biblioteca ─────────────────────────────

// class _LibraryContent extends StatelessWidget {
//   final LibraryViewModel? vm;
//   final Future<void> Function() onRefresh; 

//   const _LibraryContent({super.key, required this.vm, required this.onRefresh});

//   @override
//   Widget build(BuildContext context) {
//     if (vm == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return ValueListenableBuilder<List<LibraryResource>>(
//       valueListenable: vm!.filteredResources,
//       builder: (context, resources, _) {
//         if (resources.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.menu_book_outlined,
//                   size: 64,
//                   color: AppColors.textMuted.withOpacity(0.5),
//                 ),
//                 const SizedBox(height: AppSpacing.md),
//                 Text(
//                   'No hay recursos disponibles',
//                   style: AppTextStyles.h2.copyWith(
//                     color: AppColors.textMuted,
//                     fontSize: 18,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//         return ListView.separated(
class _LibraryContent extends StatelessWidget {
  final LibraryViewModel? vm;
  final Future<void> Function() onRefresh; // <-- nuevo

  const _LibraryContent({super.key, required this.vm, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (vm == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<List<LibraryResource>>(
      valueListenable: vm!.filteredResources,
      builder: (context, resources, _) {
        if (resources.isEmpty) {
          return ListView( // scrollable para RefreshIndicator
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 200),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.menu_book_outlined, size: 64,
                        color: AppColors.textMuted.withOpacity(0.5)),
                    const SizedBox(height: AppSpacing.md),
                    Text('No hay recursos disponibles',
                        style: AppTextStyles.h2.copyWith(
                            color: AppColors.textMuted, fontSize: 18)),
                  ],
                ),
              ),
            ],
          );
        }
        return RefreshIndicator(
          onRefresh: onRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.backgroundCard,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            itemCount: resources.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              return Hero(
                tag: 'book-${resources[index].id}',
                child: Material(
                  color: Colors.transparent,
                  child: LibraryResourceCard(
                    resource: resources[index],
                    onTap: () => vm!.onResourceTap(context, resources[index]),
                    viewModel: vm!,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
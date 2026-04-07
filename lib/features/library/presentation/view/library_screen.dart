import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/network/dio_client.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/library_di.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';
import 'package:academix/features/library/presentation/widgets/library_resource_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryViewModel? _vm;

  @override
  void initState() {
    super.initState();
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
      // Fallback: use a default id so the screen still renders
      if (!mounted) return;
      setState(() {
        _vm = LibraryDI.libraryViewModel(idUsuario: 1);
      });
    }
  }

  @override
  void dispose() {
    _vm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm;
    if (vm == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    readOnly: true,
                    onTap: () => Navigator.pushNamed(context, '/search'),
                    style: AppTextStyles.body.copyWith(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: "Buscar por tema, subtemas",
                      hintStyle: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.backgroundCard,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ValueListenableBuilder<List<String>>(
                      valueListenable: vm.categories,
                      builder: (context, categories, _) {
                        return ValueListenableBuilder<String>(
                          valueListenable: vm.selectedCategory,
                          builder: (context, selected, _) {
                            return Row(
                              children: categories.map((category) {
                                final isSelected = selected == category;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: AppSpacing.sm),
                                  child: GestureDetector(
                                    onTap: () =>
                                        vm.selectCategory(category),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(
                                                AppRadius.full),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
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
            ),
            Expanded(
              child: ValueListenableBuilder<List<LibraryResource>>(
                valueListenable: vm.filteredResources,
                builder: (context, resources, _) {
                  if (resources.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 64,
                            color: AppColors.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No hay recursos disponibles',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    itemCount: resources.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: 'book-${resources[index].id}',
                        child: Material(
                          color: Colors.transparent,
                          child: LibraryResourceCard(
                            resource: resources[index],
                            onTap: () =>
                                vm.onResourceTap(context, resources[index]),
                            viewModel: vm,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
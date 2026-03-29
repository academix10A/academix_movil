import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';

class SelectResourceBottomSheet extends StatefulWidget {
  final void Function(int, String) onResourceSelected;
  final int? preselectedId;

  const SelectResourceBottomSheet({
    super.key,
    required this.onResourceSelected,
    this.preselectedId,
  });

  static void show(BuildContext context, {int? preselectedId, required void Function(int, String) onSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectResourceBottomSheet(
        preselectedId: preselectedId,
        onResourceSelected: onSelected,
      ),
    );
  }

  @override
  State<SelectResourceBottomSheet> createState() => _SelectResourceBottomSheetState();
}

class _SelectResourceBottomSheetState extends State<SelectResourceBottomSheet> {
  late final LibraryViewModel vm;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    vm = LibraryViewModel();
    _searchController.addListener(_filterResources);
  }

  @override
  void dispose() {
    _searchController.dispose();
    vm.dispose();
    super.dispose();
  }

  void _filterResources() {
    // Filter logic will be in vm if extended, here simple
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Drag indicator
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Seleccionar recurso',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Elige el recurso para tu nota',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar recursos...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Resources list
            Expanded(
              child: ValueListenableBuilder<List<LibraryResource>>(
                valueListenable: vm.filteredResources,
                builder: (context, resources, _) {
                  if (resources.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_outlined, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: AppSpacing.md),
                          Text('No hay recursos disponibles', style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final resource = resources[index];
                      final isSelected = widget.preselectedId != null && resource.id == widget.preselectedId.toString();
                      return GestureDetector(
                        onTap: () {
                          widget.onResourceSelected(int.parse(resource.id), resource.title);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.menu_book, color: AppColors.primary),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(resource.title, style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w600)),
                                    Text(resource.category, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                                    Text('${resource.pages} págs • ${resource.durationMinutes} min', style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                              ],
                            ],
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


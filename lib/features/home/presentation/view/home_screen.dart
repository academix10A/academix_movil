import 'package:academix/features/home/presentation/widgets/course_progress_card.dart';
import 'package:academix/features/home/presentation/widgets/recent_item_card.dart';
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/home/presentation/viewmodel/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeViewModel vm = HomeViewModel();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con logo
                Text(
                  "ACADEMIX",
                  style: AppTextStyles.display.copyWith(
                    fontSize: 28,
                    letterSpacing: 1.5,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Saludo
                Text(
                  "Hola, ${vm.userName}",
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.text,
                    fontSize: 28,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  "Continúa tu aprendizaje",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Barra de búsqueda
                TextField(
                  controller: vm.searchController,
                  onSubmitted: vm.onSearch,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.background,
                  ),
                  decoration: InputDecoration(
                    hintText: "Buscar recursos, temas, notas...",
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: AppColors.text,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textMuted,
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

                const SizedBox(height: AppSpacing.xl),

                // Sección de progreso de exámenes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tu progreso en exámenes",
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Estadísticas de exámenes
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            "Exámenes realizados",
                            "${vm.examProgress['total_examenes_realizados'] ?? 0}",
                          ),
                          _buildStatItem(
                            "Completados",
                            "${vm.examProgress['examenes_completados'] ?? 0}",
                          ),
                          _buildStatItem(
                            "Promedio",
                            "${vm.examProgress['promedio_calificacion'] ?? 0}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Sección de recursos leídos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recursos leídos",
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Lista de recursos leídos
                ...vm.readResources.map(
                  (resource) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.text,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resource['titulo'] ?? '',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.background,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                LinearProgressIndicator(
                                  value: (resource['porcentaje_leido'] ?? 0) / 100,
                                  backgroundColor: AppColors.textMuted,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    resource['completado'] == true 
                                        ? AppColors.success 
                                        : AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            "${resource['porcentaje_leido'] ?? 0}%",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.background,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Sección de recientes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recientes",
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Cambiar para después conectar a API de Arath
                        // Navegar a ver todos los recientes
                      },
                      child: Text(
                        "Ver todo",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Lista de items recientes
                ...vm.recentItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: RecentItemCard(
                      item: item,
                      onTap: () => vm.onRecentItemTap(item),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h1.copyWith(
            color: AppColors.primary,
            fontSize: 24,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

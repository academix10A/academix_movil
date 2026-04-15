import 'package:academix/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/home/presentation/viewmodel/home_viewmodel.dart';
import 'package:academix/features/home/domain/entities/home_entity.dart';
import 'package:academix/features/home/presentation/widgets/recent_item_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = HomeViewModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.loadHomeData();
    });
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
                /// HEADER
                Text(
                  "ACADEMIX",
                  style: AppTextStyles.display.copyWith(
                    fontSize: 28,
                    letterSpacing: 1.5,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                /// SALUDO
                ValueListenableBuilder<String>(
                  valueListenable: vm.userName,
                  builder: (context, name, _) {
                    return Text(
                      "Hola, $name",
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.text,
                        fontSize: 28,
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  "Continúa tu aprendizaje",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                /// CARD OFFLINE MEJORADA
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 120),
                  margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () => AppNavigator.push(context, AppRoutes.offline),
                      child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.offline_share_outlined,
                                color: AppColors.background,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Contenido\nOffline",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  "Accede a tus recursos sin conexión",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),



                /// PROGRESO EXÁMENES
                Text(
                  "Tu progreso en exámenes",
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: ValueListenableBuilder<Map<String, dynamic>>(
                    valueListenable: vm.examProgress,
                    builder: (context, progress, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            "Exámenes\nrealizados",
                            "${progress['total_examenes_realizados'] ?? 0}",
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            "Completados",
                            "${progress['examenes_completados'] ?? 0}",
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            "Promedio",
                            "${progress['promedio_calificacion'] ?? 0}",
                          ),
                        ),
                      ],
                    );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                /// RECURSOS LEÍDOS
                Text(
                  "Recursos leídos",
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: vm.readResources,
                  builder: (context, resources, _) {
                    if (resources.isEmpty) {
                      return const Text("No hay recursos aún");
                    }

                    return Column(
                      children: resources.map((resource) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              onTap: () => vm.onReadResourceTap(context, resource),
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
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                /// RECIENTES
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
                      onPressed: () {},
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

                ValueListenableBuilder<List<RecentItemEntity>>(
                  valueListenable: vm.recentItems,
                  builder: (context, items, _) {
                    if (items.isEmpty) {
                      return const Text("No hay recientes");
                    }

                    return Column(
                      children: items.map((item) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: RecentItemCard(
                            item: item,
                            onTap: () => vm.onRecentItemTap(context, item),
                          ),
                        );
                      }).toList(),
                    );
                  },
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.h1.copyWith(
            color: AppColors.primary,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}
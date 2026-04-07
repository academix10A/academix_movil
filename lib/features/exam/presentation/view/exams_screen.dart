// import 'package:flutter/material.dart';
// import 'package:academix/core/constants/app_spacing.dart';
// import 'package:academix/core/themes/app_text_styles.dart';
// import 'package:academix/core/themes/app_colors.dart';
// import 'package:academix/core/constants/app_radius.dart';
// import 'package:academix/features/exam/presentation/viewmodel/exams_viewmodel.dart';
// import 'package:academix/features/exam/presentation/widgets/exam_recommended_card.dart';
// import 'package:academix/features/exam/presentation/widgets/exam_completed_card.dart';

// class ExamsScreen extends StatefulWidget {
//   const ExamsScreen({super.key});

//   @override
//   State<ExamsScreen> createState() => _ExamsScreenState();
// }

// class _ExamsScreenState extends State<ExamsScreen> {
//   final ExamsViewModel vm = ExamsViewModel();

//   @override
//   void dispose() {
//     vm.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppSpacing.lg,
//                 vertical: AppSpacing.md,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "ACADEMIX",
//                     style: AppTextStyles.display.copyWith(
//                       fontSize: 28,
//                       letterSpacing: 1.5,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.lg),
//                   Text(
//                     "Examenes",
//                     style: AppTextStyles.h1.copyWith(
//                       color: AppColors.primary,
//                       fontSize: 28,
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.xs),
//                   Text(
//                     "Evalua tu conocimiento",
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: AppColors.textMuted,
//                     ),
//                   ),
//                   const SizedBox(height: AppSpacing.lg),

//                   // Barra de búsqueda
//                   TextField(
//                     controller: vm.searchController,
//                     onSubmitted: vm.onSearch,
//                     style: AppTextStyles.body.copyWith(color: AppColors.text),
//                     decoration: InputDecoration(
//                       hintText: "Buscar por tema, materia",
//                       hintStyle: AppTextStyles.bodySmall.copyWith(
//                         color: AppColors.textMuted,
//                       ),
//                       filled: true,
//                       fillColor: AppColors.backgroundCard,
//                       prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(AppRadius.full),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: AppSpacing.lg,
//                         vertical: AppSpacing.md,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: AppSpacing.md),

//                   // Filtros Disponibles / Completados
//                   ValueListenableBuilder<ExamFilter>(
//                     valueListenable: vm.selectedFilter,
//                     builder: (context, selected, _) {
//                       return Row(
//                         children: ExamFilter.values.map((filter) {
//                           final isSelected = selected == filter;
//                           return Padding(
//                             padding: const EdgeInsets.only(right: AppSpacing.sm),
//                             child: GestureDetector(
//                               onTap: () => vm.selectFilter(filter),
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: AppSpacing.md,
//                                   vertical: AppSpacing.sm,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: isSelected
//                                       ? AppColors.primary
//                                       : Colors.transparent,
//                                   borderRadius: BorderRadius.circular(AppRadius.full),
//                                   border: Border.all(
//                                     color: isSelected
//                                         ? AppColors.primary
//                                         : AppColors.border,
//                                     width: 1.5,
//                                   ),
//                                 ),
//                                 child: Text(
//                                   filter.label,
//                                   style: AppTextStyles.bodySmall.copyWith(
//                                     color: isSelected
//                                         ? AppColors.background
//                                         : AppColors.text,
//                                     fontWeight: isSelected
//                                         ? FontWeight.w600
//                                         : FontWeight.w400,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: AppSpacing.md),

//                   // Filtros de subtemas (chips horizontales)
//                   ValueListenableBuilder<List<String>>(
//                     valueListenable: vm.availableSubtemas,
//                     builder: (context, subtemas, _) {
//                       if (subtemas.isEmpty) return const SizedBox.shrink();
//                       return ValueListenableBuilder<String?>(
//                         valueListenable: vm.selectedSubtema,
//                         builder: (context, selectedSub, _) {
//                           return SizedBox(
//                             height: 36,
//                             child: ListView(
//                               scrollDirection: Axis.horizontal,
//                               children: [
//                                 // Chip "Todos"
//                                 _SubtemaChip(
//                                   label: 'Todos',
//                                   isSelected: selectedSub == null,
//                                   onTap: () => vm.selectSubtema(null),
//                                 ),
//                                 const SizedBox(width: AppSpacing.sm),
//                                 ...subtemas.map((sub) => Padding(
//                                   padding: const EdgeInsets.only(right: AppSpacing.sm),
//                                   child: _SubtemaChip(
//                                     label: sub,
//                                     isSelected: selectedSub == sub,
//                                     onTap: () => vm.selectSubtema(sub),
//                                   ),
//                                 )),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // Contenido scrollable
//             Expanded(
//               child: ValueListenableBuilder<bool>(
//                 valueListenable: vm.isLoading,
//                 builder: (context, loading, _) {
//                   if (loading) {
//                     return const Center(
//                       child: CircularProgressIndicator(color: AppColors.primary),
//                     );
//                   }
//                   return SingleChildScrollView(
//                     padding: EdgeInsets.only(
//                       left: AppSpacing.lg,
//                       right: AppSpacing.lg,
//                       top: AppSpacing.sm,
//                       bottom: MediaQuery.of(context).padding.bottom + 100,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Error message
//                         ValueListenableBuilder<String?>(
//                           valueListenable: vm.errorMessage,
//                           builder: (context, error, _) {
//                             if (error == null) return const SizedBox.shrink();
//                             return Container(
//                               margin: const EdgeInsets.only(bottom: AppSpacing.md),
//                               padding: const EdgeInsets.all(AppSpacing.md),
//                               decoration: BoxDecoration(
//                                 color: AppColors.error.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(AppRadius.md),
//                                 border: Border.all(color: AppColors.error.withOpacity(0.3)),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.error_outline, color: AppColors.error, size: 18),
//                                   const SizedBox(width: AppSpacing.sm),
//                                   Expanded(
//                                     child: Text(
//                                       error,
//                                       style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),

//                         // Sección: Recomendados / Disponibles
//                         ValueListenableBuilder<List<ExamItem>>(
//                           valueListenable: vm.recommendedExams,
//                           builder: (context, exams, _) {
//                             if (exams.isEmpty) {
//                               return ValueListenableBuilder<ExamFilter>(
//                                 valueListenable: vm.selectedFilter,
//                                 builder: (context, filter, _) {
//                                   if (filter != ExamFilter.disponibles) return const SizedBox.shrink();
//                                   return Center(
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(top: AppSpacing.xxl),
//                                       child: Column(
//                                         children: [
//                                           Icon(Icons.quiz_outlined, size: 48, color: AppColors.textMuted),
//                                           const SizedBox(height: AppSpacing.md),
//                                           Text(
//                                             'No hay exámenes disponibles',
//                                             style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             }
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Recomendados para ti",
//                                   style: AppTextStyles.h2.copyWith(color: AppColors.text),
//                                 ),
//                                 const SizedBox(height: AppSpacing.md),
//                                 ...exams.map(
//                                   (exam) => Padding(
//                                     padding: const EdgeInsets.only(bottom: AppSpacing.md),
//                                     child: ExamRecommendedCard(
//                                       exam: exam,
//                                       onStart: () => vm.onStartExam(context, exam),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: AppSpacing.lg),
//                               ],
//                             );
//                           },
//                         ),

//                         // Sección: Completados recientemente
//                         ValueListenableBuilder<List<CompletedExamItem>>(
//                           valueListenable: vm.completedExams,
//                           builder: (context, exams, _) {
//                             if (exams.isEmpty) {
//                               return ValueListenableBuilder<ExamFilter>(
//                                 valueListenable: vm.selectedFilter,
//                                 builder: (context, filter, _) {
//                                   if (filter != ExamFilter.completados) return const SizedBox.shrink();
//                                   return Center(
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(top: AppSpacing.xxl),
//                                       child: Column(
//                                         children: [
//                                           Icon(Icons.check_circle_outline, size: 48, color: AppColors.textMuted),
//                                           const SizedBox(height: AppSpacing.md),
//                                           Text(
//                                             'Aún no has completado exámenes',
//                                             style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             }
//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   "Completados recientemente",
//                                   style: AppTextStyles.h2.copyWith(color: AppColors.text),
//                                 ),
//                                 const SizedBox(height: AppSpacing.md),
//                                 ...exams.map(
//                                   (exam) => Padding(
//                                     padding: const EdgeInsets.only(bottom: AppSpacing.md),
//                                     child: ExamCompletedCard(
//                                       exam: exam,
//                                       onTap: () => vm.onCompletedExamTap(context, exam),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),

//                         const SizedBox(height: AppSpacing.xxl),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SubtemaChip extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _SubtemaChip({
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.primary.withOpacity(0.15)
//               : AppColors.backgroundCard,
//           borderRadius: BorderRadius.circular(AppRadius.full),
//           border: Border.all(
//             color: isSelected ? AppColors.primary : AppColors.border,
//             width: 1.5,
//           ),
//         ),
//         child: Text(
//           label,
//           style: AppTextStyles.bodySmall.copyWith(
//             color: isSelected ? AppColors.primary : AppColors.textMuted,
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/exam/presentation/viewmodel/exams_viewmodel.dart';
import 'package:academix/features/exam/presentation/widgets/exam_recommended_card.dart';
import 'package:academix/features/exam/presentation/widgets/exam_completed_card.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final ExamsViewModel vm = ExamsViewModel();

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
                    "Examenes",
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Evalua tu conocimiento",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Barra de búsqueda
                  TextField(
                    controller: vm.searchController,
                    onSubmitted: vm.onSearch,
                    style: AppTextStyles.body.copyWith(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: "Buscar por tema, materia",
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
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

                  // Filtros Disponibles / Completados
                  ValueListenableBuilder<ExamFilter>(
                    valueListenable: vm.selectedFilter,
                    builder: (context, selected, _) {
                      return Row(
                        children: ExamFilter.values.map((filter) {
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

                  const SizedBox(height: AppSpacing.md),

                  // Filtros de subtemas (chips horizontales)
                  ValueListenableBuilder<List<String>>(
                    valueListenable: vm.availableSubtemas,
                    builder: (context, subtemas, _) {
                      if (subtemas.isEmpty) return const SizedBox.shrink();
                      return ValueListenableBuilder<String?>(
                        valueListenable: vm.selectedSubtema,
                        builder: (context, selectedSub, _) {
                          return SizedBox(
                            height: 36,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _SubtemaChip(
                                  label: 'Todos',
                                  isSelected: selectedSub == null,
                                  onTap: () => vm.selectSubtema(null),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                ...subtemas.map((sub) => Padding(
                                      padding: const EdgeInsets.only(
                                          right: AppSpacing.sm),
                                      child: _SubtemaChip(
                                        label: sub,
                                        isSelected: selectedSub == sub,
                                        onTap: () => vm.selectSubtema(sub),
                                      ),
                                    )),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: vm.isLoading,
                builder: (context, loading, _) {
                  if (loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      top: AppSpacing.sm,
                      bottom: MediaQuery.of(context).padding.bottom + 100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message
                        ValueListenableBuilder<String?>(
                          valueListenable: vm.errorMessage,
                          builder: (context, error, _) {
                            if (error == null) return const SizedBox.shrink();
                            return Container(
                              margin: const EdgeInsets.only(
                                  bottom: AppSpacing.md),
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                    color:
                                        AppColors.error.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: AppColors.error, size: 18),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style:
                                          AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Sección: Recomendados / Disponibles
                        ValueListenableBuilder<List<ExamItem>>(
                          valueListenable: vm.recommendedExams,
                          builder: (context, exams, _) {
                            if (exams.isEmpty) {
                              return ValueListenableBuilder<ExamFilter>(
                                valueListenable: vm.selectedFilter,
                                builder: (context, filter, _) {
                                  if (filter != ExamFilter.disponibles)
                                    return const SizedBox.shrink();
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: AppSpacing.xxl),
                                      child: Column(
                                        children: [
                                          Icon(Icons.quiz_outlined,
                                              size: 48,
                                              color: AppColors.textMuted),
                                          const SizedBox(
                                              height: AppSpacing.md),
                                          Text(
                                            'No hay exámenes disponibles',
                                            style: AppTextStyles.body
                                                .copyWith(
                                                    color:
                                                        AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Recomendados para ti",
                                  style: AppTextStyles.h2
                                      .copyWith(color: AppColors.text),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                ...exams.map(
                                  (exam) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: AppSpacing.md),
                                    child: ExamRecommendedCard(
                                      exam: exam,
                                      onStart: () =>
                                          vm.onStartExam(context, exam),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],
                            );
                          },
                        ),

                        // Sección: Completados
                        ValueListenableBuilder<ExamFilter>(
                          valueListenable: vm.selectedFilter,
                          builder: (context, filter, _) {
                            if (filter != ExamFilter.completados) {
                              return const SizedBox.shrink();
                            }

                            return ValueListenableBuilder<bool>(
                              valueListenable: vm.noDesglosPermission,
                              builder: (context, noPermiso, _) {
                                // Sin permiso de desglose
                                if (noPermiso) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: AppSpacing.xxl),
                                      child: Column(
                                        children: [
                                          Icon(Icons.lock_outline,
                                              size: 48,
                                              color: AppColors.textMuted),
                                          const SizedBox(
                                              height: AppSpacing.md),
                                          Text(
                                            'Necesitas un plan superior\npara ver el historial detallado',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.body
                                                .copyWith(
                                                    color:
                                                        AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                // Con permiso: lista de completados
                                return ValueListenableBuilder<List<CompletedExamItem>>(
                                  valueListenable: vm.completedExams,
                                  builder: (context, exams, _) {
                                    if (exams.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: AppSpacing.xxl),
                                          child: Column(
                                            children: [
                                              Icon(
                                                  Icons
                                                      .check_circle_outline,
                                                  size: 48,
                                                  color:
                                                      AppColors.textMuted),
                                              const SizedBox(
                                                  height: AppSpacing.md),
                                              Text(
                                                'Aún no has completado exámenes',
                                                style: AppTextStyles.body
                                                    .copyWith(
                                                        color: AppColors
                                                            .textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Completados recientemente",
                                          style: AppTextStyles.h2.copyWith(
                                              color: AppColors.text),
                                        ),
                                        const SizedBox(
                                            height: AppSpacing.md),
                                        ...exams.map(
                                          (exam) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: AppSpacing.md),
                                            child: ExamCompletedCard(
                                              exam: exam,
                                              onTap: () =>
                                                  vm.onCompletedExamTap(
                                                      context, exam),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
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

class _SubtemaChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubtemaChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
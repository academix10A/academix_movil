import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/exam/presentation/viewmodel/exam_history_viewmodel.dart';

class ExamHistoryScreen extends StatefulWidget {
  const ExamHistoryScreen({super.key});

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  late final ExamHistoryViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = ExamHistoryViewModel();
    vm.loadHistory();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
                    "Historial de Exámenes",
                    style: AppTextStyles.h1
                        .copyWith(color: AppColors.primary, fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "Tus resultados anteriores",
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: vm.isLoading,
                builder: (context, loading, _) {
                  if (loading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }
                  return ValueListenableBuilder<List<ExamHistoryGroup>>(
                    valueListenable: vm.historyGroups,
                    builder: (context, groups, _) {
                      if (groups.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_edu_outlined,
                                  size: 56, color: AppColors.textMuted),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No hay exámenes realizados',
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        itemCount: groups.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return _ExamHistoryGroupCard(
                            group: groups[index],
                            onTapIntento: (intento) =>
                                vm.onTapIntento(context, groups[index], intento),
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
    );
  }
}

/// Card que muestra un examen con todos sus intentos agrupados
class _ExamHistoryGroupCard extends StatefulWidget {
  final ExamHistoryGroup group;
  final void Function(ExamIntentoItem intento) onTapIntento;

  const _ExamHistoryGroupCard({
    required this.group,
    required this.onTapIntento,
  });

  @override
  State<_ExamHistoryGroupCard> createState() => _ExamHistoryGroupCardState();
}

class _ExamHistoryGroupCardState extends State<_ExamHistoryGroupCard> {
  bool _expanded = false;

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _gradeLabel(int score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final best = widget.group.bestScore;
    final color = _scoreColor(best);
    final hasMultiple = widget.group.intentos.length > 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Cabecera principal
          InkWell(
            onTap: hasMultiple
                ? () => setState(() => _expanded = !_expanded)
                : () => widget.onTapIntento(widget.group.intentos.first),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.group.title,
                              style: AppTextStyles.h2.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.group.subtema != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.group.subtema!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Badge de mejor calificación
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${best}%',
                              style: AppTextStyles.h2.copyWith(
                                color: color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _gradeLabel(best),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(Icons.history_rounded,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        hasMultiple
                            ? '${widget.group.intentos.length} intentos · Mejor: ${best}%'
                            : widget.group.intentos.first.timeAgo,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (hasMultiple) ...[
                        const Spacer(),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lista de intentos expandida (premium)
          if (_expanded && hasMultiple)
            Column(
              children: [
                Divider(color: AppColors.border, height: 1),
                ...widget.group.intentos.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final intento = entry.value;
                  final iColor = _scoreColor(intento.score);
                  return InkWell(
                    onTap: () => widget.onTapIntento(intento),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        border: idx < widget.group.intentos.length - 1
                            ? Border(
                                bottom: BorderSide(
                                    color: AppColors.border, width: 0.5))
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Número de intento
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '#${intento.numero}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Intento ${intento.numero}',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.text,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  intento.timeAgo,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Score del intento
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: iColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              '${intento.score}%',
                              style: AppTextStyles.body.copyWith(
                                color: iColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/note/presentation/viewmodel/notes_viewmodel.dart';

class NoteCard extends StatelessWidget {
  final NoteItem note;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título + fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.text,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  note.timeAgo,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Preview del contenido
            Text(
              note.preview,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.md),

            // Tags (categoría + compartida)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                // Tags de materia
                ...note.tags.map(
                  (tag) => _TagChip(
                    label: tag,
                    color: AppColors.primary,
                    textColor: AppColors.background,
                  ),
                ),
                // Badge de compartida
                if (note.isShared)
                  _TagChip(
                    label: 'Compartida',
                    color: Colors.transparent,
                    textColor: AppColors.accent,
                    borderColor: AppColors.accent,
                  ),
                // Resource indicator
                if (note.hasResource)
                  _TagChip(
                    label: '${note.resource!.title.substring(0, 15)}${note.resource!.title.length > 15 ? '...' : ''}',
                    color: AppColors.accent.withOpacity(0.1),
                    textColor: AppColors.accent,
                    borderColor: AppColors.accent,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Color? borderColor;

  const _TagChip({
    required this.label,
    required this.color,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
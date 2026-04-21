import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.isPopular,
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
          border: Border.all(
            color: isPopular ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      'POPULAR',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.text,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.accent,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    feature,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPopular ? AppColors.accent : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: Text(
                  isPopular ? 'Obtener ahora' : 'Seleccionar',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


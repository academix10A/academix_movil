import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Premium Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  'Mejora a Premium',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Subtitle
                Text(
                  'Desbloquea todo el potencial de Academix',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Benefits List
                _BenefitItem(
                  icon: Icons.library_books,
                  title: 'Acceso Ilimitado',
                  description: 'Accede a todos los recursos sin restricciones',
                ),
                _BenefitItem(
                  icon: Icons.analytics,
                  title: 'Análisis Avanzado',
                  description: 'Estadísticas detalladas de tu progreso',
                ),
                _BenefitItem(
                  icon: Icons.school,
                  title: 'Exámenes Premium',
                  description: 'Exámenes exclusivos con preguntas avanzadas',
                ),
                _BenefitItem(
                  icon: Icons.notifications_active,
                  title: 'Notificaciones Prioritarias',
                  description: 'Recibe alertas instantáneas',
                ),
                _BenefitItem(
                  icon: Icons.cloud_download,
                  title: 'Descarga Offline',
                  description: 'Guarda recursos para ver sin conexión',
                ),
                _BenefitItem(
                  icon: Icons.support_agent,
                  title: 'Soporte Prioritario',
                  description: 'Atención al cliente 24/7',
                ),

                const SizedBox(height: AppSpacing.xl),

                // Plans
                Text(
                  'Elige tu plan',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.text,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Plan Cards
                _PlanCard(
                  title: 'Mensual',
                  price: '\$99',
                  period: '/mes',
                  features: [
                    'Todos los beneficios premium',
                    'Acceso inmediato',
                    'Cancela cuando quieras',
                  ],
                  isPopular: false,
                  onTap: () {
                    // TODO: Implement purchase
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente...')),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                _PlanCard(
                  title: 'Anual',
                  price: '\$799',
                  period: '/año',
                  features: [
                    'Todos los beneficios premium',
                    'Ahorra 33%',
                    '2 meses gratis',
                    'Soporte prioritario',
                  ],
                  isPopular: true,
                  onTap: () {
                    // TODO: Implement purchase
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente...')),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // FAQ
                ExpansionTile(
                  title: Text(
                    '¿Tengo garantía de reembolso?',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  iconColor: AppColors.textMuted,
                  collapsedIconColor: AppColors.textMuted,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'Sí, tienes 7 días de garantía de reembolso. Si no estás satisfecho, te devolvemos tu dinero.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  title: Text(
                    '¿Puedo cancelar en cualquier momento?',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  iconColor: AppColors.textMuted,
                  collapsedIconColor: AppColors.textMuted,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'Sí, puedes cancelar tu membresía en cualquier momento. Seguirás tendo acceso hasta el final del período pagado.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final VoidCallback onTap;

  const _PlanCard({
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


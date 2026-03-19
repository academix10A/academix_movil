import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/profile/presentation/viewmodel/membresia_viewmodel.dart';
import 'package:academix/features/profile/presentation/widgets/plan_card.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final MembresiaViewModel vm = MembresiaViewModel();

  @override
  void initState() {
    super.initState();

    vm.addListener(() {
      setState(() {});
    });

    vm.loadMembresias();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  Widget _buildPlans() {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Text(vm.error!);
    }

    final planes = vm.membresias
        .where((p) => p.tipo != 'Freemium')
        .toList();

    if (planes.isEmpty) {
      return const Text('No hay planes disponibles');
    }

    return Column(
      children: planes.map((plan) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: PlanCard(
            title: plan.tipo,
            price: '\$${plan.costo}',
            period: '/${plan.tipo.toLowerCase()}',
            features: plan.beneficios.map((b) => b.nombre).toList(),
            isPopular: plan.tipo == 'Anual',
            onTap: () {
              print('Seleccionado: ${plan.nombre}');
            },
          ),
        );
      }).toList(),
    );
  }

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
                _buildPlans(),

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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/profile/domain/entities/membresia_entity.dart';
import 'package:academix/features/profile/domain/usecases/membresia_usecases.dart';
import 'package:academix/features/profile/presentation/viewmodel/membresia_viewmodel.dart';
import 'package:academix/features/profile/presentation/viewmodel/profile_viewmodel.dart';
import 'package:academix/features/profile/presentation/widgets/paypal_webview.dart';

class PremiumScreen extends StatefulWidget {
  final MembresiaViewModel membresiaVm;
  final ProfileViewModel profileVm;
  final CreatePaypalOrderUseCase createPaypalOrder;
  final CapturePaypalOrderUseCase capturePaypalOrder;
  final ActivarMembresiaUseCase activarMembresia;

  const PremiumScreen({
    super.key,
    required this.membresiaVm,
    required this.profileVm,
    required this.createPaypalOrder,
    required this.capturePaypalOrder,
    required this.activarMembresia,
  });

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  Membresia? _selectedPlan;
  bool _showSuccess = false;
  bool _isPaying = false;

  late AnimationController _successController;
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _successController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _buttonScale =
        CurvedAnimation(parent: _buttonController, curve: Curves.elasticOut);

    widget.profileVm.loadProfileData();
    widget.membresiaVm.addListener(() {
      if (mounted) setState(() {});
    });
    widget.membresiaVm.loadMembresias();
  }

  @override
  void dispose() {
    _successController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _selectPlan(Membresia plan) {
    HapticFeedback.selectionClick();
    setState(() => _selectedPlan = plan);
    _buttonController.forward(from: 0);
  }

  void _onPaymentSuccess() {
    widget.profileVm.refreshProfile();
    setState(() => _showSuccess = true);
    _successController.forward();
    HapticFeedback.heavyImpact();
  }

  Future<void> _handlePayment() async {
    if (_selectedPlan == null || _isPaying) return;
    final plan = _selectedPlan!;

    if (plan.costo == 0) {
      setState(() => _isPaying = true);
      try {
        await widget.profileVm.purchaseMembresia(plan);
        _onPaymentSuccess();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isPaying = false);
      }
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PayPalWebView(
          idMembresia: plan.id,
          onSuccess: _onPaymentSuccess,
          onCancel: () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pago cancelado.')));
            }
          },
          createPaypalOrder: widget.createPaypalOrder,
          capturePaypalOrder: widget.capturePaypalOrder,
          activarMembresia: widget.activarMembresia,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) return _SuccessView(onDone: () => Navigator.pop(context));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFFFD700).withOpacity(0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: widget.membresiaVm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : widget.membresiaVm.error != null
                          ? Center(child: Text(widget.membresiaVm.error!))
                          : _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.text, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text('PREMIUM',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final planes = widget.membresiaVm.membresias
        .where((p) => p.tipo != 'Freemium')
        .toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Desbloquea\ntu potencial',
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.5)),
                const SizedBox(height: 8),
                Text('Elige el plan que mejor se adapta a ti',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 15)),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final plan = planes[index];
                final isSelected = _selectedPlan?.id == plan.id;
                final isPopular =
                    plan.tipo.toLowerCase().contains('mensual');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _PlanCard(
                    plan: plan,
                    isSelected: isSelected,
                    isPopular: isPopular,
                    onTap: () => _selectPlan(plan),
                  ),
                );
              },
              childCount: planes.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: _buttonScale,
            builder: (context, child) {
              return AnimatedOpacity(
                opacity: _selectedPlan != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: AnimatedSlide(
                  offset: _selectedPlan != null
                      ? Offset.zero
                      : const Offset(0, 0.3),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _PayButton(
                plan: _selectedPlan,
                isPaying: _isPaying,
                onTap: _handlePayment,
              ),
            ),
          ),
        ),
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        //     child: Column(
        //       children: [
        //         _FaqTile(
        //           question: '¿Tengo garantía de reembolso?',
        //           answer:
        //               'Sí, tienes 7 días de garantía de reembolso. Si no estás satisfecho, te devolvemos tu dinero.',
        //         ),
        //         const SizedBox(height: 8),
        //         _FaqTile(
        //           question: '¿Puedo cancelar en cualquier momento?',
        //           answer:
        //               'Sí, puedes cancelar tu membresía en cualquier momento. Seguirás teniendo acceso hasta el final del período pagado.',
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final Membresia plan;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : const Color(0xFF20234A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(0.07),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 6))
                ]
              : [],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 2),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.3),
                    width: 2),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan.tipo,
                          style: TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [
                              Color(0xFFFFD700),
                              Color(0xFFFFA500)
                            ]),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Popular',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...plan.beneficios.take(3).map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 13,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textMuted),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(b.nombre,
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: '\$',
                        style: TextStyle(
                            color:
                                isSelected ? AppColors.primary : AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    TextSpan(
                        text: '${plan.costo}',
                        style: TextStyle(
                            color:
                                isSelected ? AppColors.primary : AppColors.text,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1)),
                  ]),
                ),
                Text('/${plan.tipo.toLowerCase()}',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pay Button ───────────────────────────────────────────────────────────────

class _PayButton extends StatelessWidget {
  final Membresia? plan;
  final bool isPaying;
  final VoidCallback onTap;

  const _PayButton(
      {required this.plan, required this.isPaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFree = plan?.costo == 0;
    return GestureDetector(
      onTap: isPaying ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: isFree
              ? LinearGradient(colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8)
                ])
              : const LinearGradient(
                  colors: [Color(0xFF0070BA), Color(0xFF003087)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: (isFree ? AppColors.primary : const Color(0xFF0070BA))
                    .withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Center(
          child: isPaying
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        isFree ? Icons.bolt_rounded : Icons.payment_rounded,
                        color: Colors.white,
                        size: 20),
                    const SizedBox(width: 8),
                    Text(
                        isFree
                            ? 'Activar gratis'
                            : 'Pagar \$${plan?.costo} con PayPal',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── FAQ Tile ─────────────────────────────────────────────────────────────────

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: const Color(0xFF20234A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(widget.question,
                        style: TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600))),
                AnimatedRotation(
                  turns: _open ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: AppColors.textMuted),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(widget.answer,
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 13, height: 1.5)),
              ),
              crossFadeState:
                  _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Success View ─────────────────────────────────────────────────────────────

class _SuccessView extends StatefulWidget {
  final VoidCallback onDone;
  const _SuccessView({required this.onDone});

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5)
                        ],
                      ),
                      child: const Icon(Icons.workspace_premium_rounded,
                          size: 54, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('¡Bienvenido\na Premium!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 12),
                  Text(
                      'Tu membresía está activa.\nYa tienes acceso a todo el contenido.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 15, height: 1.5)),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: widget.onDone,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: const Center(
                          child: Text('Ir al perfil',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:academix/core/widgets/app_button_navigation.dart';
import 'package:academix/features/library/presentation/view/library_screen.dart';
import 'package:academix/features/note/presentation/view/notes_screen.dart';
import 'package:academix/features/exam/presentation/view/exams_screen.dart';
import 'package:academix/features/profile/presentation/view/profile_screen.dart';
import 'package:academix/features/home/presentation/view/home_screen.dart';
import 'package:academix/features/publication/presentation/view/publications_screen.dart';
import 'package:academix/features/profile/profile_di.dart';
import 'package:academix/features/exam/exam_dependencies.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _menuOpen = false;
  OverlayEntry? _overlayEntry;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const PublicationsScreen(),
    const NotesScreen(),
    ExamDependenciesProvider(
      dependencies: ExamDependencies(),
      child: const ExamsScreen(),
    ),
    ProfileScreen(vm: ProfileDI.profileViewModel),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  void _openMenu() {
    if (_menuOpen) return;
    setState(() => _menuOpen = true);

    _overlayEntry = OverlayEntry(
      builder: (context) => _BubbleOverlay(
        onPublicacionesTap: () {
          _closeMenu();
          _onTabTapped(2);
        },
        onNotasTap: () {
          _closeMenu();
          _onTabTapped(3);
        },
        onDismiss: _closeMenu,
        navBarHeight: kBottomNavigationBarHeight +
            MediaQuery.of(context).padding.bottom,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    if (!_menuOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _menuOpen = false);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        isMenuOpen: _menuOpen,
        onToggleMenu: () => _menuOpen ? _closeMenu() : _openMenu(),
      ),
    );
  }
}

// ── Overlay con burbujas ──────────────────────────────────────────────────────
class _BubbleOverlay extends StatefulWidget {
  final VoidCallback onPublicacionesTap;
  final VoidCallback onNotasTap;
  final VoidCallback onDismiss;
  final double navBarHeight;

  const _BubbleOverlay({
    required this.onPublicacionesTap,
    required this.onNotasTap,
    required this.onDismiss,
    required this.navBarHeight,
  });

  @override
  State<_BubbleOverlay> createState() => _BubbleOverlayState();
}

class _BubbleOverlayState extends State<_BubbleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo semitransparente que detecta tap fuera
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ),

        // Burbujas sobre la barra
        Positioned(
          bottom: widget.navBarHeight + 16,
          left: 0,
          right: 0,
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FloatingBubble(
                    icon: Icons.article_rounded,
                    label: 'Publicaciones',
                    onTap: widget.onPublicacionesTap,
                  ),
                  const SizedBox(width: 24),
                  _FloatingBubble(
                    icon: Icons.note_rounded,
                    label: 'Notas',
                    onTap: widget.onNotasTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class _FloatingBubble extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const _FloatingBubble({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Import AppColors aquí o mueve la clase a otro archivo
//     const primary = Color(0xFFD4AF37);
//     const backgroundCard = Color(0xFF1E2E50);
//     const backgroundElevated = Color(0xFF1A365D);
//     const border = Color(0x1AFFFFFF);

//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Container(
//           //   width: 62,
//           //   height: 62,
//           //   decoration: BoxDecoration(
//           //     color: backgroundCard,
//           //     shape: BoxShape.circle,
//           //     border: Border.all(color: primary, width: 2),
//           //     boxShadow: [
//           //       BoxShadow(
//           //         color: Colors.black.withValues(alpha: 0.4),
//           //         blurRadius: 14,
//           //         offset: const Offset(0, 4),
//           //       ),
//           //     ],
//           //   ),
//           //   child: const Icon(Icons.article_rounded, // se sobreescribe abajo
//           //       color: primary, size: 26),
//           // ),
//           Container(
//             width: 62,
//             height: 62,
//             decoration: BoxDecoration(
//               color: backgroundCard,
//               shape: BoxShape.circle,
//               border: Border.all(color: primary, width: 2),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.4),
//                   blurRadius: 14,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Icon(icon, color: primary, size: 26),  // <-- usa el parámetro
//           ),
//           const SizedBox(height: 6),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: backgroundElevated,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: border, width: 1),
//             ),
//             child: Text(
//               label,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _FloatingBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FloatingBubble({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFD4AF37);
    const backgroundCard = Color(0xFF1E2E50);
    const backgroundElevated = Color(0xFF1A365D);
    const border = Color(0x1AFFFFFF);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: backgroundCard,
              shape: BoxShape.circle,
              border: Border.all(color: primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: primary, size: 26),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: 1),
            ),
            child: Text(
              label,
              overflow: TextOverflow.visible,   // <-- sin subrayado de overflow
              softWrap: false,                  // <-- no parte en dos líneas
              style: const TextStyle(
                fontFamily: 'RedHatDisplay',    // <-- tu fuente
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none, // <-- quita cualquier subrayado
              ),
            ),
          ),
        ],
      ),
    );
  }
}
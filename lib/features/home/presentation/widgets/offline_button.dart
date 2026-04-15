import 'package:flutter/material.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/library/domain/entities/library_resource_entity.dart';
import '../viewmodel/offline_di.dart';
import '../viewmodel/offline_viewmodel.dart';

class OfflineButton extends StatefulWidget {
  final LibraryResourceEntity recurso;
  final bool esPremium;

  const OfflineButton({
    super.key,
    required this.recurso,
    required this.esPremium,
  });

  @override
  State<OfflineButton> createState() => _OfflineButtonState();
}

class _OfflineButtonState extends State<OfflineButton> {
  late final OfflineViewModel _vm;
  bool    _guardado = false;
  bool    _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _vm = OfflineDI.viewModel();
    if (widget.esPremium) _verificarEstado();
  }

  Future<void> _verificarEstado() async {
    final esta = await _vm.estaGuardado(widget.recurso.idRecurso);
    if (mounted) setState(() => _guardado = esta);
  }

  // Convierte la entity a mapa para el datasource local
  Map<String, dynamic> get _mapa => {
    'id_recurso':  widget.recurso.idRecurso,
    'titulo':      widget.recurso.titulo,
    'descripcion': widget.recurso.descripcion ?? '',
    'contenido':   widget.recurso.contenido,
    'url_archivo': widget.recurso.urlArchivo,
    'id_tipo':     widget.recurso.idTipo,
    'id_subtema':  widget.recurso.idSubtema,
    'external_id': null,
  };

  Future<void> _guardar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      await _vm.guardar(_mapa);
      if (mounted) setState(() => _guardado = true);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo guardar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      await _vm.eliminar(widget.recurso.idRecurso, widget.recurso.urlArchivo);
      if (mounted) setState(() => _guardado = false);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo eliminar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.esPremium) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildButton() {
    if (_cargando) {
      return _Btn(
        icon: const SizedBox(
          width: 14, height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        label: 'Guardando…',
        color: AppColors.textMuted,
        onTap: null,
      );
    }
    if (_guardado) {
      return _Btn(
        icon: const Icon(Icons.check_circle, size: 15, color: Colors.white),
        label: 'Guardado offline',
        color: AppColors.success,
        trailing: const Icon(Icons.delete_outline, size: 14, color: Colors.white70),
        onTap: _eliminar,
      );
    }
    return _Btn(
      icon: const Icon(Icons.download_rounded, size: 15, color: Colors.white),
      label: 'Guardar offline',
      color: AppColors.primary,
      onTap: _guardar,
    );
  }
}

class _Btn extends StatelessWidget {
  final Widget    icon;
  final String    label;
  final Color     color;
  final Widget?   trailing;
  final VoidCallback? onTap;

  const _Btn({
    required this.icon,
    required this.label,
    required this.color,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 5),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
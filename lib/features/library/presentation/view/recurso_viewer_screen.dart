// lib/features/library/presentation/view/recurso_viewer_screen.dart
// Visor universal — equivalente al RecursoViewer.jsx de la web.
// Detecta el tipo de URL y renderiza el widget correcto.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/library/presentation/viewmodel/url_detector.dart';

class RecursoViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const RecursoViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<RecursoViewerScreen> createState() => _RecursoViewerScreenState();
}

class _RecursoViewerScreenState extends State<RecursoViewerScreen> {
  late final UrlType _urlType;

  @override
  void initState() {
    super.initState();
    _urlType = UrlDetector.detect(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.text,
              size: 22,
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Botón abrir en navegador externo
          IconButton(
            onPressed: () async {
              final uri = Uri.parse(widget.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_new_rounded,
                color: AppColors.textMuted, size: 20),
            tooltip: 'Abrir en navegador',
          ),
        ],
      ),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    // WebView: Drive, YouTube, Gutenberg, OpenLibrary, Archive, HTML
    if (UrlDetector.isWebViewType(_urlType)) {
      final embedUrl = _urlType == UrlType.drive
          ? UrlDetector.getDriveEmbedUrl(widget.url)
          : _urlType == UrlType.youtube
              ? UrlDetector.getYoutubeEmbedUrl(widget.url)
              : widget.url;

      return _WebViewContent(url: embedUrl, title: widget.title);
    }

    // PDF nativo (descarga + flutter_pdfview)
    if (UrlDetector.isNativePdf(_urlType)) {
      return _PdfContent(url: widget.url, title: widget.title);
    }

    // Audio
    if (_urlType == UrlType.audio) {
      return _AudioContent(url: widget.url, title: widget.title);
    }

    // Video directo (mp4, etc.)
    if (_urlType == UrlType.video) {
      return _VideoFallback(url: widget.url, title: widget.title);
    }

    // Unknown — botón para abrir externamente
    return _UnknownContent(url: widget.url);
  }
}

// ── WebView ────────────────────────────────────────────────────────────────────

class _WebViewContent extends StatefulWidget {
  final String url;
  final String title;
  const _WebViewContent({required this.url, required this.title});

  @override
  State<_WebViewContent> createState() => _WebViewContentState();
}

class _WebViewContentState extends State<_WebViewContent> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

// ── PDF nativo ─────────────────────────────────────────────────────────────────

class _PdfContent extends StatefulWidget {
  final String url;
  final String title;
  const _PdfContent({required this.url, required this.title});

  @override
  State<_PdfContent> createState() => _PdfContentState();
}

class _PdfContentState extends State<_PdfContent> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 0;
  int totalPages = 0;
  PDFViewController? _pdfController;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode != 200) {
        setState(() {
          errorMessage = 'Error al descargar (${response.statusCode})';
          isLoading = false;
        });
        return;
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/pdf_${widget.url.hashCode.abs()}.pdf');
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'No se pudo descargar el PDF.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoading('Descargando PDF…');
    if (errorMessage != null) return _buildError(errorMessage!);

    return Column(
      children: [
        Expanded(
          child: PDFView(
            filePath: localPath!,
            enableSwipe: true,
            autoSpacing: true,
            pageFling: true,
            fitEachPage: true,
            onRender: (pages) => setState(() => totalPages = pages ?? 0),
            onViewCreated: (c) => _pdfController = c,
            onPageChanged: (page, total) => setState(() {
              currentPage = page ?? 0;
              totalPages = total ?? 0;
            }),
            onError: (e) => setState(() => errorMessage = e.toString()),
          ),
        ),
        if (totalPages > 0) _buildPageControls(),
      ],
    );
  }

  Widget _buildPageControls() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
            top: BorderSide(color: AppColors.backgroundCard, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pageBtn(Icons.chevron_left_rounded, currentPage > 0,
                () => _pdfController?.setPage(currentPage - 1)),
            Text('${currentPage + 1} / $totalPages',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted)),
            _pageBtn(Icons.chevron_right_rounded, currentPage < totalPages - 1,
                () => _pdfController?.setPage(currentPage + 1)),
          ],
        ),
      ),
    );
  }

  Widget _pageBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.backgroundCard
              : AppColors.backgroundCard.withOpacity(0.4),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon,
            color: enabled
                ? AppColors.text
                : AppColors.textMuted.withOpacity(0.3),
            size: 28),
      ),
    );
  }
}

// ── Audio ──────────────────────────────────────────────────────────────────────

class _AudioContent extends StatefulWidget {
  final String url;
  final String title;
  const _AudioContent({required this.url, required this.title});

  @override
  State<_AudioContent> createState() => _AudioContentState();
}

class _AudioContentState extends State<_AudioContent> {
  late final AudioPlayer _player;
  bool _loading = true;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setUrl(widget.url);
      _duration = _player.duration ?? Duration.zero;
      _player.positionStream.listen(
          (p) => setState(() => _position = p));
      _player.playingStream.listen(
          (playing) => setState(() => _playing = playing));
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar el audio.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading('Cargando audio…');
    if (_error != null) return _buildError(_error!);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.headphones_rounded,
                  size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(widget.title,
                style: AppTextStyles.h2.copyWith(color: AppColors.text),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),

            // Progress
            Slider(
              value: _position.inSeconds
                  .toDouble()
                  .clamp(0, _duration.inSeconds.toDouble()),
              max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.backgroundCard,
              onChanged: (v) =>
                  _player.seek(Duration(seconds: v.toInt())),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted)),
                Text(_fmt(_duration),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Play/Pause
            GestureDetector(
              onTap: () =>
                  _playing ? _player.pause() : _player.play(),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: AppColors.background,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Video fallback (abre externamente) ────────────────────────────────────────

class _VideoFallback extends StatelessWidget {
  final String url;
  final String title;
  const _VideoFallback({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.play_circle_outline_rounded,
                      size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title,
                style: AppTextStyles.h2.copyWith(color: AppColors.text),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text('Abre el video en tu app de video.',
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.open_in_new_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Abrir video',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Unknown ────────────────────────────────────────────────────────────────────

class _UnknownContent extends StatelessWidget {
  final String url;
  const _UnknownContent({required this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_rounded,
                size: 64, color: AppColors.textMuted.withOpacity(0.4)),
            const SizedBox(height: AppSpacing.lg),
            Text('No se puede previsualizar este recurso.',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.open_in_new_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Abrir recurso',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

Widget _buildLoading(String msg) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppSpacing.md),
        Text(msg,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textMuted)),
      ],
    ),
  );
}

Widget _buildError(String msg) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
                color: AppColors.backgroundCard, shape: BoxShape.circle),
            child:
                const Icon(Icons.error_outline_rounded,
                    color: Colors.redAccent, size: 48),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('No se pudo cargar el recurso',
              style: AppTextStyles.h2.copyWith(color: AppColors.text),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(msg,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
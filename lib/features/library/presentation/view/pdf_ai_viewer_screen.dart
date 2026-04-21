import 'dart:convert';
import 'dart:typed_data';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/utils/env.dart';
import 'package:academix/features/library/presentation/view/ai_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class PdfAiViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfAiViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfAiViewerScreen> createState() => _PdfAiViewerScreenState();
}

class _PdfAiViewerScreenState extends State<PdfAiViewerScreen> {
  WebViewController? _controller;

  bool    _loading = true;
  bool    _showAiButton = false;
  String  _selectedText = '';
  String? _errorCarga;

  // ── Paso 1: descargar PDF y convertir a data URL ───────────────────────────
  Future<String> _resolveToDataUrl(String url) async {
    if (url.startsWith('data:')) return url;

    final backendBase = _backendRoot(Env.apiUrl);
    final proxiedUrl =
        '$backendBase/api/proxy/pdf?url=${Uri.encodeComponent(url)}';

    final response = await http
        .get(Uri.parse(proxiedUrl))
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode} al descargar el PDF');
    }

    final b64 = base64Encode(Uint8List.fromList(response.bodyBytes));
    return 'data:application/pdf;base64,$b64';
  }

  String _backendRoot(String apiBase) {
    final clean = apiBase.replaceAll(RegExp(r'/+$'), '');
    return clean.endsWith('/api')
        ? clean.substring(0, clean.length - 4)
        : clean;
  }

  // ── Paso 2: construir el WebViewController ya con la data URL lista ────────
  Future<WebViewController> _buildController(String dataUrl) async {
    final htmlContent =
        await rootBundle.loadString('assets/pdfjs/pdf_ai_viewer.html');

    late final WebViewController controller;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1E1E1E))
      ..enableZoom(true)
      ..addJavaScriptChannel(
        'SelectionChannel',
        onMessageReceived: (message) {
          try {
            final raw = message.message.trim();
            if (!raw.startsWith('{')) return;

            final data = jsonDecode(raw) as Map<String, dynamic>;

            switch (data['type']?.toString()) {
              case 'selection_changed':
                _handleSelectionChanged(
                  data['text']?.toString() ?? '',
                );
                break;

              case 'selection_cleared':
                _handleSelectionCleared();
                break;

              case 'ask_ai':
                final text =
                    data['text']?.toString().trim() ?? '';

                if (text.isEmpty) return;

                _handleSelectionChanged(text);
                _openAiChat();
                break;
            }
          } catch (e) {
            debugPrint('SelectionChannel error: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);

            if (uri?.scheme == 'academix' &&
                uri?.host == 'ask-ai') {
              final text =
                  uri!.queryParameters['text']?.trim() ?? '';

              if (text.isNotEmpty) {
                _handleSelectionChanged(text);
                _openAiChat();
              }

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },

          onPageFinished: (_) async {
            final escaped = dataUrl
                .replaceAll('\\', '\\\\')
                .replaceAll("'", "\\'");

            await controller.runJavaScript(
              "renderPdf('$escaped');",
            );

            if (mounted) {
              setState(() => _loading = false);
            }
          },

          onWebResourceError: (error) {
            if (error.url?.contains('about:blank') == true) {
              return;
            }

            debugPrint(
              'WEBVIEW ERROR: ${error.description}',
            );
          },
        ),
      );

    await controller.loadHtmlString(
      htmlContent,
      baseUrl:
          'file:///android_asset/flutter_assets/assets/pdfjs/',
    );

    return controller;
  }

  // ── Flujo principal: resolve → build → mostrar ────────────────────────────
  Future<void> _init() async {
    try {
      final dataUrl    = await _resolveToDataUrl(widget.pdfUrl);
      final controller = await _buildController(dataUrl);
      if (!mounted) return;
      setState(() => _controller = controller);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCarga = 'No se pudo cargar el PDF.\n${e.toString()}';
        _loading    = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  // ── Selección / IA ─────────────────────────────────────────────────────────
  void _handleSelectionChanged(String text) {
    final clean = text.trim();
    if (!mounted) return;
    setState(() { _selectedText = clean; _showAiButton = clean.isNotEmpty; });
  }

  void _handleSelectionCleared() {
    if (!mounted) return;
    setState(() { _selectedText = ''; _showAiButton = false; });
  }

  Future<void> _openAiChat() async {
    final text = _selectedText.trim();
    if (text.isEmpty) return;
    try {
      await _controller?.runJavaScript('clearSelectionFromApp();');
    } catch (_) {}
    if (!mounted) return;
    setState(() => _showAiButton = false);
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AiChatScreen(initialContext: text)),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Color(0xFF1E1E1E))),

          // WebView — solo se monta cuando el controller está listo
          if (_controller != null)
            Positioned.fill(
              child: WebViewWidget(controller: _controller!),
            ),

          // Spinner mientras se descarga el PDF o carga el HTML
          if (_loading)
            const Center(child: CircularProgressIndicator()),

          // Error de carga
          if (_errorCarga != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      _errorCarga!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // Hint de selección
          if (!_loading && _errorCarga == null)
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _showAiButton ? 0.0 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Mantén presionado sobre el texto para seleccionarlo y preguntarle a la IA.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),

          // Botón IA
          if (_showAiButton)
            Positioned(
              right: AppSpacing.md,
              bottom: 72,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: FloatingActionButton.extended(
                    // heroTag: 'pdf_ai_fab',
                    heroTag: null,
                    onPressed: _openAiChat,
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0F2340),
                    elevation: 8,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text(
                      'Preguntar a la IA',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
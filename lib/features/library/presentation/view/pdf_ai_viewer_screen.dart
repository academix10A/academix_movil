import 'dart:convert';

import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/utils/env.dart';
import 'package:academix/features/library/presentation/view/ai_chat_screen.dart';
import 'package:flutter/material.dart';
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
  late final WebViewController _controller;
  bool _loading = true;

  String _backendRoot(String apiBase) {
    final clean = apiBase.replaceAll(RegExp(r'/+$'), '');
    if (clean.endsWith('/api')) {
      return clean.substring(0, clean.length - 4);
    }
    return clean;
  }

  @override
  void initState() {
    super.initState();

    final backendBase = _backendRoot(Env.apiUrl);
    final proxiedPdfUrl =
        '$backendBase/api/proxy/pdf?url=${Uri.encodeComponent(widget.pdfUrl)}';
    final viewerUrl =
        '$backendBase/api/proxy/pdf-viewer?pdfUrl=${Uri.encodeComponent(proxiedPdfUrl)}';

    _controller = WebViewController()
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
            final type = data['type']?.toString();

            if (type == 'ask_ai') {
              final text = data['text']?.toString().trim() ?? '';
              if (text.isEmpty) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiChatScreen(initialContext: text),
                ),
              );
            }
          } catch (e) {
            debugPrint('SelectionChannel parse error: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);

            if (uri != null && uri.scheme == 'academix' && uri.host == 'ask-ai') {
              final text = uri.queryParameters['text']?.trim() ?? '';
              if (text.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiChatScreen(initialContext: text),
                  ),
                );
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            debugPrint('WEBVIEW ERROR: ${error.description}');
          },
        ),
      )
      ..clearCache()
      ..loadRequest(Uri.parse(viewerUrl));
  }

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
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        ],
      ),
    );
  }
}

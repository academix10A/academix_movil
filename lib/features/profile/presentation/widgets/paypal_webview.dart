import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:academix/features/profile/domain/usecases/membresia_usecases.dart';

class PayPalWebView extends StatefulWidget {
  final int idMembresia;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  // Use cases injected — the widget never touches the data layer directly
  final CreatePaypalOrderUseCase createPaypalOrder;
  final CapturePaypalOrderUseCase capturePaypalOrder;
  final ActivarMembresiaUseCase activarMembresia;

  const PayPalWebView({
    super.key,
    required this.idMembresia,
    required this.onSuccess,
    required this.onCancel,
    required this.createPaypalOrder,
    required this.capturePaypalOrder,
    required this.activarMembresia,
  });

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late final WebViewController controller;
  bool _isLoading = true;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_isCapturing) return;
            if (url.contains('academix.app/paypal/success')) {
              _captureFromUrl(url);
            } else if (url.contains('academix.app/paypal/cancel')) {
              widget.onCancel();
              if (mounted) Navigator.pop(context);
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (error.url?.contains('academix.app') == true) return;
            if (error.errorCode == -202) return;
            if (error.errorType == WebResourceErrorType.unsupportedScheme) {
              return;
            }
            debugPrint(
              'PayPal WebView error [${error.errorCode}]: '
              '${error.description} — url: ${error.url}',
            );
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.contains('academix.app/paypal/success')) {
              _captureFromUrl(url);
              return NavigationDecision.prevent;
            }
            if (url.contains('academix.app/paypal/cancel')) {
              widget.onCancel();
              if (mounted) Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _loadPayPal();
  }

  void _captureFromUrl(String url) {
    if (_isCapturing) return;
    final orderId = Uri.parse(url).queryParameters['token'];
    if (orderId == null || orderId.isEmpty) {
      debugPrint('PayPal: token no encontrado en URL: $url');
      widget.onCancel();
      if (mounted) Navigator.pop(context);
      return;
    }
    _captureOrder(orderId);
  }

  Future<void> _loadPayPal() async {
    try {
      final result = await widget.createPaypalOrder(widget.idMembresia);
      final approvalUrl = result['approvalUrl'] as String?;
      if (approvalUrl == null || approvalUrl.isEmpty) {
        debugPrint('PayPal: approvalUrl vacía o nula');
        widget.onCancel();
        if (mounted) Navigator.pop(context);
        return;
      }
      controller.loadRequest(Uri.parse(approvalUrl));
    } catch (e) {
      debugPrint('Error loading PayPal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'No se pudo conectar con PayPal. Intenta de nuevo.')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _captureOrder(String orderId) async {
    _isCapturing = true;
    if (mounted) setState(() => _isLoading = true);

    try {
      await widget.capturePaypalOrder(orderId, widget.idMembresia);
      await widget.activarMembresia(widget.idMembresia);
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Capture/activation error: $e');
      _isCapturing = false;
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error al procesar el pago. Contacta soporte si se realizó el cobro.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
        widget.onCancel();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagar con PayPal')),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
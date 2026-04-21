import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';

class PdfViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 0;
  int totalPages = 0;
  PDFViewController? _pdfController;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));

      if (response.statusCode != 200) {
        setState(() {
          errorMessage =
              'No se pudo cargar el PDF (Error ${response.statusCode})';
          isLoading = false;
        });
        return;
      }

      final dir = await getTemporaryDirectory();
      // Nombre único por URL para evitar colisiones entre recursos
      final fileName =
          'pdf_${widget.url.hashCode.abs()}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al descargar el PDF.\nVerifica tu conexión.';
        isLoading = false;
      });
    }
  }

  void _goToPreviousPage() {
    if (currentPage > 0) {
      _pdfController?.setPage(currentPage - 1);
    }
  }

  void _goToNextPage() {
    if (currentPage < totalPages - 1) {
      _pdfController?.setPage(currentPage + 1);
    }
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
          if (totalPages > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? _buildLoading()
          : errorMessage != null
              ? _buildError()
              : _buildPdfViewer(),
      bottomNavigationBar: (!isLoading && errorMessage == null && totalPages > 0)
          ? _buildPageControls()
          : null,
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Cargando PDF...',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No se pudo cargar el PDF',
              style: AppTextStyles.h2.copyWith(color: AppColors.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorMessage ?? '',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _downloadAndLoadPdf();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'Reintentar',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    return PDFView(
      filePath: localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      fitEachPage: true,
      onRender: (pages) {
        setState(() => totalPages = pages ?? 0);
      },
      onViewCreated: (controller) {
        _pdfController = controller;
      },
      onPageChanged: (page, total) {
        setState(() {
          currentPage = page ?? 0;
          totalPages = total ?? 0;
        });
      },
      onError: (error) {
        setState(() => errorMessage = error.toString());
      },
      onPageError: (page, error) {
        debugPrint('Error en página $page: $error');
      },
    );
  }

  Widget _buildPageControls() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.backgroundCard,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Página anterior
            GestureDetector(
              onTap: currentPage > 0 ? _goToPreviousPage : null,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: currentPage > 0
                      ? AppColors.backgroundCard
                      : AppColors.backgroundCard.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: currentPage > 0
                      ? AppColors.text
                      : AppColors.textMuted.withOpacity(0.3),
                  size: 28,
                ),
              ),
            ),

            // Indicador de página
            Text(
              'Página ${currentPage + 1} de $totalPages',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),

            // Página siguiente
            GestureDetector(
              onTap: currentPage < totalPages - 1 ? _goToNextPage : null,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: currentPage < totalPages - 1
                      ? AppColors.backgroundCard
                      : AppColors.backgroundCard.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: currentPage < totalPages - 1
                      ? AppColors.text
                      : AppColors.textMuted.withOpacity(0.3),
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
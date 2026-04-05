// lib/features/library/core/url_detector.dart
// Detecta el tipo de URL — equivalente al urlDetector.js de la web

enum UrlType {
  drive,
  youtube,
  openLibrary,
  gutenberg,
  archive,
  audio,
  video,
  pdf,
  html,
  unknown,
}

class UrlDetector {
  static UrlType detect(String? url) {
    if (url == null || url.isEmpty) return UrlType.unknown;
    final u = url.toLowerCase();

    if (u.contains('drive.google.com')) return UrlType.drive;
    if (u.contains('youtube.com') || u.contains('youtu.be')) return UrlType.youtube;
    if (u.contains('openlibrary.org')) return UrlType.openLibrary;
    if (u.contains('gutenberg.org')) return UrlType.gutenberg;
    if (u.contains('archive.org')) return UrlType.archive;
    if (u.contains('vimeo.com')) return UrlType.video;
    if (u.contains('open.spotify.com')) return UrlType.audio;
    if (u.contains('soundcloud.com')) return UrlType.audio;

    if (u.endsWith('.mp3') ||
        u.endsWith('.wav') ||
        u.endsWith('.ogg') ||
        u.endsWith('.aac') ||
        u.endsWith('.m4a')) return UrlType.audio;

    if (u.endsWith('.mp4') ||
        u.endsWith('.webm') ||
        u.endsWith('.mov') ||
        u.endsWith('.avi')) return UrlType.video;

    if (u.endsWith('.pdf')) return UrlType.pdf;

    if (u.endsWith('.html') || u.endsWith('.htm')) return UrlType.html;

    return UrlType.unknown;
  }

  /// Drive: /file/d/ID/view → /file/d/ID/preview
  static String getDriveEmbedUrl(String url) {
    final match = RegExp(r'/file/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    if (match != null) {
      return 'https://drive.google.com/file/d/${match.group(1)}/preview';
    }
    return url;
  }

  /// YouTube: watch?v=ID o youtu.be/ID → embed/ID
  static String getYoutubeEmbedUrl(String url) {
    // watch?v=
    final watchMatch =
        RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (watchMatch != null) {
      return 'https://www.youtube.com/embed/${watchMatch.group(1)}?rel=0&modestbranding=1';
    }
    // youtu.be/
    final shortMatch =
        RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})').firstMatch(url);
    if (shortMatch != null) {
      return 'https://www.youtube.com/embed/${shortMatch.group(1)}?rel=0&modestbranding=1';
    }
    return url;
  }

  /// Devuelve true si el tipo se puede mostrar en un WebView
  static bool isWebViewType(UrlType type) {
    return type == UrlType.drive ||
        type == UrlType.youtube ||
        type == UrlType.openLibrary ||
        type == UrlType.gutenberg ||
        type == UrlType.archive ||
        type == UrlType.html;
  }

  /// Devuelve true si el tipo requiere descarga local (PDF nativo)
  static bool isNativePdf(UrlType type) => type == UrlType.pdf;

  /// Devuelve true si es audio o video
  static bool isMedia(UrlType type) =>
      type == UrlType.audio || type == UrlType.video;
}
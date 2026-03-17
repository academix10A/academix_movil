import 'package:flutter/material.dart';

class AppColors {
  // Core - Matched to Web: dark blue/gold theme
  static const text = Color(0xFFFFFFFF); // white
  static const background = Color(0xFF0F2340); // --blue-dark
  static const primary = Color(0xFFD4AF37); // --gold main primary
  static const secondary = Color(0xFFE8B84B); // gold-light variant
  static const accent = Color(0xFF63B3ED); // --blue-light accent

  // Extended - Web dark sections
  static const backgroundElevated = Color(0xFF1A365D); // --blue-strong
  static const backgroundCard = Color(0xFF1E2E50); // card dark blue
  static const backgroundHover = Color(0xFF2B6CB0); // --blue-mid hover
  static const textMuted = Color(0xFF99A3B0); // rgba(255,255,255,0.6)
  static const textDimmed = Color(0xFF5A6B7A); // rgba(255,255,255,0.4)
  static const border = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)

  // Off-white for light web sections
  static const offWhite = Color(0xFFF0F4F8);

  // Semantic (kept similar)
  static const success = Color(0xFF00D084);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFFF5252);
}

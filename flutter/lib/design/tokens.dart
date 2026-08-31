// GENERATED FILE. DO NOT EDIT.
import 'package:flutter/material.dart';

class RTokens {
  RTokens._();

  // ─── Legacy brand (kept for compatibility) ───────────────────────────────
  static const brandPrimary = Color(0xFF0EA5E9);
  static const brandPrimaryDark = Color(0xFF0369A1);
  static const brandSurface = Color(0xFFF0F9FF);
  static const neutralBg = Color(0xFFF8FAFC);
  static const neutralCard = Color(0xFFFFFFFF);
  static const neutralText = Color(0xFF0F172A);
  static const neutralMuted = Color(0xFF475569);
  static const neutralBorder = Color(0xFFE2E8F0);
  static const statusSuccess = Color(0xFF15803D);
  static const statusWarning = Color(0xFFA16207);
  static const statusDanger = Color(0xFFB91C1C);

  // ─── Dark / Glass backgrounds ─────────────────────────────────────────────
  static const glassBg = Color(0xFF08080F);
  static const glassSurface = Color(0xFF0D0D1A);
  static const glassElevated = Color(0xFF12122A);

  // Glass card surface: rgba(255,255,255,0.05) and border rgba(255,255,255,0.10)
  static const glassCardBg = Color(0x0DFFFFFF);
  static const glassCardBgHover = Color(0x17FFFFFF);
  static const glassCardBorder = Color(0x1AFFFFFF);
  static const glassCardBorderStrong = Color(0x2EFFFFFF);

  // ─── Glassmorphism brand palette ──────────────────────────────────────────
  static const violet = Color(0xFF7C3AED);
  static const violetLight = Color(0xFFA78BFA);
  static const blue = Color(0xFF3B82F6);
  static const amber = Color(0xFFF59E0B);
  static const emerald = Color(0xFF10B981);

  // ─── Text on dark ─────────────────────────────────────────────────────────
  static const textOnDark = Color(0xFFFFFFFF);
  static const textMutedDark = Color(0xFF94A3B8);
  static const textSubtleDark = Color(0xFF475569);

  // ─── Glow colors (for BoxShadow) ──────────────────────────────────────────
  static const glowViolet = Color(0x737C3AED);      // violet at 45%
  static const glowVioletSm = Color(0x4D7C3AED);    // violet at 30%
  static const glowBlue = Color(0x663B82F6);         // blue at 40%
  static const glowAmber = Color(0x59F59E0B);        // amber at 35%
  static const glowEmerald = Color(0x5910B981);      // emerald at 35%

  // ─── Spacing ──────────────────────────────────────────────────────────────
  static const double spacingX1 = 4.0;
  static const double spacingX2 = 8.0;
  static const double spacingX3 = 12.0;
  static const double spacingX4 = 16.0;
  static const double spacingX6 = 24.0;
  static const double spacingX8 = 32.0;

  // ─── Border radius ────────────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;

  // ─── Font sizes ───────────────────────────────────────────────────────────
  static const double textXs = 12.0;
  static const double textSm = 14.0;
  static const double textBase = 16.0;
  static const double textLg = 18.0;
  static const double textXl = 20.0;
  static const double textX2l = 24.0;
  static const double textX3l = 30.0;
  static const double textX4l = 36.0;

  // ─── Glass card decoration helper ─────────────────────────────────────────
  static BoxDecoration glassDecoration({double radius = radiusXl}) => BoxDecoration(
    color: glassCardBg,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: glassCardBorder, width: 1),
    boxShadow: const [
      BoxShadow(color: Color(0x66000000), blurRadius: 32, offset: Offset(0, 8)),
      BoxShadow(color: Color(0x0FFFFFFF), blurRadius: 0, spreadRadius: 1),
    ],
  );

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(color: color, blurRadius: 40, spreadRadius: -8),
  ];
}

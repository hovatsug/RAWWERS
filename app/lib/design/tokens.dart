import 'package:flutter/widgets.dart';

/// Raw design tokens - the only place a color/size literal should exist in
/// the app. Everything else (theme_client.dart, theme_pro.dart, components)
/// references these, never a bare hex or number.
///
/// Contrast ratios noted below are WCAG 2.1 relative-luminance
/// calculations, checked by hand against the two extreme backgrounds
/// (RInk.i950, RInk.i050) this app actually uses. Given how close to pure
/// black/white those are, ~4.29:1 is the theoretical ceiling for *any*
/// single hex against both simultaneously - no accent choice clears 4.5:1
/// (AA normal text) on both ends at once, which is why the accent is never
/// used for body-sized text without a non-color signal (underline) beside
/// it - see RAccent doc comment.
abstract final class RInk {
  static const i950 = Color(0xFF0E0F11);
  static const i900 = Color(0xFF1A1B1E);
  static const i800 = Color(0xFF232427);
  static const i600 = Color(0xFF56585C);
  static const i500 = Color(0xFF6B6D70);
  static const i400 = Color(0xFF9A9CA0);
  static const i200 = Color(0xFFE4E4E3);
  static const i100 = Color(0xFFEFEFEE);
  static const i050 = Color(0xFFFAFAFA);
}

/// "Meter blue" - a light-meter-dial blue, deliberately cool so it never
/// competes with warm skin tones the way the first (rejected) red-orange
/// draft did. Same hex in both apps/themes - a deliberate cross-app
/// consistency signal.
abstract final class RAccent {
  /// Icons, borders, selection rings, progress fill, links (always paired
  /// with an underline - see contrast note above). 4.45:1 vs RInk.i950,
  /// 4.13:1 vs RInk.i050 - clears AA for graphical objects/large text (3:1)
  /// on both, not normal body text on either.
  static const meter500 = Color(0xFF4A7FA5);

  /// Button fills specifically - darker, so white/i050 label text clears
  /// AA normal-text comfortably (8.3:1), which meter500 itself can't
  /// guarantee for text this small.
  static const meter700 = Color(0xFF2C4F66);
}

/// Positive-terminal booking states (DELIVERED, CLOSED). "Developed" - a
/// photo fully realized - rather than a generic success green.
abstract final class RDevelop {
  static const develop500 = Color(0xFF5B7A63);
}

/// Stopped booking states (CANCELLED, DISPUTED) - filled, not outline
/// (unlike every other status chip), because these are the two states a
/// photographer must notice immediately. shade600 fill + i050 text is
/// 7.0:1, comfortably clearing AA.
abstract final class RShade {
  static const shade600 = Color(0xFF46586B);
}

/// One 8px grid. Infrastructure, not visual identity - deliberately not
/// trying to be clever here.
abstract final class RSpace {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s48 = 48.0;
  static const s64 = 64.0;
}

/// Deliberately low, split by content type: photography is rectangular
/// (prints, negatives, contact-sheet frames), so photo content gets 0 -
/// full-bleed, sharp. No stadium/full-pill shapes anywhere.
abstract final class RRadius {
  static const photo = 0.0;
  static const control = 4.0;
  static const surface = 8.0;
  static const sheet = 16.0;
}

/// Border-based elevation almost everywhere (a 1px hairline, see
/// RInk.i800/i200 as border colors in the themes) instead of shadows.
/// This is the one exception: genuinely floating/temporary surfaces only
/// (sheets, dialogs, snackbars, the pinned selection-gallery total bar).
abstract final class RElevation {
  static const shadowFloat = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 16,
    offset: Offset(0, -2),
  );
}

/// Two tiers: UI (the workhorse - dense data, pro app tables) and Display
/// (rare, big moments - empty states, hero numbers). No ratio story
/// attached to these sizes; they're just a sensible, compact scale.
abstract final class RType {
  static const caption = 11.0;
  static const label = 13.0;
  static const body = 15.0;
  static const title = 18.0;
  static const displaySm = 20.0;
  static const displayMd = 28.0;
  static const displayLg = 40.0;

  static const lineHeightUi = 1.4;
  static const lineHeightDisplay = 1.15;

  static const fontFamily = 'Archivo';

  // Variable-font weight axis values (Archivo-Variable.ttf ships Thin-Black;
  // these are the only three this app uses).
  static const weightRegular = FontVariation('wght', 400);
  static const weightMedium = FontVariation('wght', 500);
  static const weightSemibold = FontVariation('wght', 600);

  /// Enables tabular (fixed-width) lining figures - required wherever a
  /// number appears in a data-table-like context: pro dashboard balances,
  /// pricing tables, calendar grids, gig counts, SLA countdowns.
  static const tabularFigures = [FontFeature.tabularFigures()];
}

/// Minimum touch target, applied to every tappable control regardless of
/// its visual size (part of the F-4 quality floor).
const rMinTouchTarget = 44.0;

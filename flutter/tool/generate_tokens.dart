import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current.path;
  final tokenFile = File('$root/../web/design-system/tokens.json');
  if (!tokenFile.existsSync()) {
    stderr.writeln('Missing tokens file at ${tokenFile.path}');
    exitCode = 1;
    return;
  }

  final json = jsonDecode(tokenFile.readAsStringSync()) as Map<String, dynamic>;

  final colors = json['colors'] as Map<String, dynamic>;
  final spacing = json['spacing'] as Map<String, dynamic>;
  final radii = json['radii'] as Map<String, dynamic>;
  final typography = json['typography'] as Map<String, dynamic>;

  final brand = colors['brand'] as Map<String, dynamic>;
  final neutral = colors['neutral'] as Map<String, dynamic>;
  final status = colors['status'] as Map<String, dynamic>;

  String hexToColorLiteral(String hex) {
    final clean = hex.replaceFirst('#', '');
    return 'Color(0xFF${clean.toUpperCase()})';
  }

  final tokensOut = StringBuffer()
    ..writeln('// GENERATED FILE. DO NOT EDIT.')
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln('')
    ..writeln('class RTokens {')
    ..writeln('  RTokens._();')
    ..writeln('')
    ..writeln('  static const brandPrimary = ${hexToColorLiteral(brand['primary'] as String)};')
    ..writeln('  static const brandPrimaryDark = ${hexToColorLiteral(brand['primaryDark'] as String)};')
    ..writeln('  static const brandSurface = ${hexToColorLiteral(brand['surface'] as String)};')
    ..writeln('  static const neutralBg = ${hexToColorLiteral(neutral['bg'] as String)};')
    ..writeln('  static const neutralCard = ${hexToColorLiteral(neutral['card'] as String)};')
    ..writeln('  static const neutralText = ${hexToColorLiteral(neutral['text'] as String)};')
    ..writeln('  static const neutralMuted = ${hexToColorLiteral(neutral['muted'] as String)};')
    ..writeln('  static const neutralBorder = ${hexToColorLiteral(neutral['border'] as String)};')
    ..writeln('  static const statusSuccess = ${hexToColorLiteral(status['success'] as String)};')
    ..writeln('  static const statusWarning = ${hexToColorLiteral(status['warning'] as String)};')
    ..writeln('  static const statusDanger = ${hexToColorLiteral(status['danger'] as String)};')
    ..writeln('')
    ..writeln('  static const double spacingX1 = ${(spacing['x1'] as num).toDouble()};')
    ..writeln('  static const double spacingX2 = ${(spacing['x2'] as num).toDouble()};')
    ..writeln('  static const double spacingX3 = ${(spacing['x3'] as num).toDouble()};')
    ..writeln('  static const double spacingX4 = ${(spacing['x4'] as num).toDouble()};')
    ..writeln('  static const double spacingX6 = ${(spacing['x6'] as num).toDouble()};')
    ..writeln('  static const double spacingX8 = ${(spacing['x8'] as num).toDouble()};')
    ..writeln('')
    ..writeln('  static const double radiusSm = ${(radii['sm'] as num).toDouble()};')
    ..writeln('  static const double radiusMd = ${(radii['md'] as num).toDouble()};')
    ..writeln('  static const double radiusLg = ${(radii['lg'] as num).toDouble()};')
    ..writeln('')
    ..writeln('  static const double textXs = ${(typography['xs'] as num).toDouble()};')
    ..writeln('  static const double textSm = ${(typography['sm'] as num).toDouble()};')
    ..writeln('  static const double textBase = ${(typography['base'] as num).toDouble()};')
    ..writeln('  static const double textLg = ${(typography['lg'] as num).toDouble()};')
    ..writeln('  static const double textXl = ${(typography['xl'] as num).toDouble()};')
    ..writeln('  static const double textX2l = ${(typography['x2l'] as num).toDouble()};')
    ..writeln('}');

  final themeOut = StringBuffer()
    ..writeln('// GENERATED FILE. DO NOT EDIT.')
    ..writeln("import 'package:flutter/material.dart';")
    ..writeln("import 'tokens.dart';")
    ..writeln('')
    ..writeln('ThemeData buildLightTheme() {')
    ..writeln('  final colorScheme = const ColorScheme.light(')
    ..writeln('    primary: RTokens.brandPrimary,')
    ..writeln('    onPrimary: Colors.white,')
    ..writeln('    secondary: RTokens.brandPrimaryDark,')
    ..writeln('    surface: RTokens.neutralCard,')
    ..writeln('    onSurface: RTokens.neutralText,')
    ..writeln('    error: RTokens.statusDanger,')
    ..writeln('    onError: Colors.white,')
    ..writeln('  );')
    ..writeln('')
    ..writeln('  final textTheme = const TextTheme(')
    ..writeln('    headlineMedium: TextStyle(fontSize: RTokens.textX2l, fontWeight: FontWeight.w700, color: RTokens.neutralText),')
    ..writeln('    titleLarge: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w600, color: RTokens.neutralText),')
    ..writeln('    titleMedium: TextStyle(fontSize: RTokens.textLg, fontWeight: FontWeight.w600, color: RTokens.neutralText),')
    ..writeln('    bodyLarge: TextStyle(fontSize: RTokens.textBase, color: RTokens.neutralText),')
    ..writeln('    bodyMedium: TextStyle(fontSize: RTokens.textSm, color: RTokens.neutralText),')
    ..writeln('    bodySmall: TextStyle(fontSize: RTokens.textXs, color: RTokens.neutralMuted),')
    ..writeln('  );')
    ..writeln('')
    ..writeln('  return ThemeData(')
    ..writeln('    useMaterial3: true,')
    ..writeln('    colorScheme: colorScheme,')
    ..writeln('    scaffoldBackgroundColor: RTokens.neutralBg,')
    ..writeln('    textTheme: textTheme,')
    ..writeln('    cardTheme: CardThemeData(')
    ..writeln('      color: RTokens.neutralCard,')
    ..writeln('      margin: EdgeInsets.zero,')
    ..writeln('      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RTokens.radiusLg)),')
    ..writeln('      elevation: 0,')
    ..writeln('    ),')
    ..writeln('    inputDecorationTheme: InputDecorationTheme(')
    ..writeln('      filled: true,')
    ..writeln('      fillColor: RTokens.neutralCard,')
    ..writeln('      contentPadding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX3, vertical: RTokens.spacingX2),')
    ..writeln('      border: OutlineInputBorder(')
    ..writeln('        borderRadius: BorderRadius.circular(RTokens.radiusMd),')
    ..writeln('        borderSide: const BorderSide(color: RTokens.neutralBorder),')
    ..writeln('      ),')
    ..writeln('      enabledBorder: OutlineInputBorder(')
    ..writeln('        borderRadius: BorderRadius.circular(RTokens.radiusMd),')
    ..writeln('        borderSide: const BorderSide(color: RTokens.neutralBorder),')
    ..writeln('      ),')
    ..writeln('      focusedBorder: OutlineInputBorder(')
    ..writeln('        borderRadius: BorderRadius.circular(RTokens.radiusMd),')
    ..writeln('        borderSide: const BorderSide(color: RTokens.brandPrimary),')
    ..writeln('      ),')
    ..writeln('    ),')
    ..writeln('    elevatedButtonTheme: ElevatedButtonThemeData(')
    ..writeln('      style: ElevatedButton.styleFrom(')
    ..writeln('        backgroundColor: RTokens.brandPrimary,')
    ..writeln('        foregroundColor: Colors.white,')
    ..writeln('        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RTokens.radiusMd)),')
    ..writeln('        padding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX4, vertical: RTokens.spacingX2),')
    ..writeln('      ),')
    ..writeln('    ),')
    ..writeln('  );')
    ..writeln('}')
    ..writeln('')
    ..writeln('ThemeData buildDarkTheme() {')
    ..writeln('  final base = ThemeData.dark(useMaterial3: true);')
    ..writeln('  return base.copyWith(')
    ..writeln('    colorScheme: base.colorScheme.copyWith(primary: RTokens.brandPrimary),')
    ..writeln('  );')
    ..writeln('}');

  final designDir = Directory('$root/lib/design');
  if (!designDir.existsSync()) {
    designDir.createSync(recursive: true);
  }

  File('${designDir.path}/tokens.dart').writeAsStringSync(tokensOut.toString());
  File('${designDir.path}/theme.dart').writeAsStringSync(themeOut.toString());

  stdout.writeln('Generated lib/design/tokens.dart and lib/design/theme.dart');
}

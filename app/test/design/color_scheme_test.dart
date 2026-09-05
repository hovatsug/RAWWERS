import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/design/tokens.dart';

/// The design system has exactly one accent. The way it acquired a second was
/// silent: `ColorScheme.light(...)` fills unnamed roles from Flutter's
/// baseline Material palette, `NavigationBar`'s indicator reads
/// `secondaryContainer`, and a bright teal pill appeared in the pro app with
/// no hex anywhere in the source to grep for.
///
/// These walk every colour role in both schemes and assert each one is a
/// token. A role added by a future Flutter version, or a role someone drops
/// from the scheme, fails here rather than on a device.
/// A list rather than a Set: `Color` no longer has primitive equality (the
/// wide-gamut rewrite gave it a colorSpace field), so it cannot be a const
/// Set element. `contains` still compares with `==`, which is what matters.
const _allowed = <Color>[
  RInk.i950, RInk.i900, RInk.i800, RInk.i600, RInk.i500, RInk.i400,
  RInk.i200, RInk.i100, RInk.i050,
  RAccent.meter500, RAccent.meter700,
  RDevelop.develop500,
  RShade.shade600,
  Color(0x33000000), // shadow
  Color(0x99000000), // scrim
  Color(0x00000000), // surfaceTint, deliberately off
];

/// Every colour-valued getter on ColorScheme, named so a missing one is a
/// visible omission rather than an implicit pass.
Map<String, Color> _roles(ColorScheme s) => {
      'primary': s.primary,
      'onPrimary': s.onPrimary,
      'primaryContainer': s.primaryContainer,
      'onPrimaryContainer': s.onPrimaryContainer,
      'secondary': s.secondary,
      'onSecondary': s.onSecondary,
      'secondaryContainer': s.secondaryContainer,
      'onSecondaryContainer': s.onSecondaryContainer,
      'tertiary': s.tertiary,
      'onTertiary': s.onTertiary,
      'tertiaryContainer': s.tertiaryContainer,
      'onTertiaryContainer': s.onTertiaryContainer,
      'error': s.error,
      'onError': s.onError,
      'errorContainer': s.errorContainer,
      'onErrorContainer': s.onErrorContainer,
      'surface': s.surface,
      'onSurface': s.onSurface,
      'onSurfaceVariant': s.onSurfaceVariant,
      'surfaceContainerLowest': s.surfaceContainerLowest,
      'surfaceContainerLow': s.surfaceContainerLow,
      'surfaceContainer': s.surfaceContainer,
      'surfaceContainerHigh': s.surfaceContainerHigh,
      'surfaceContainerHighest': s.surfaceContainerHighest,
      'outline': s.outline,
      'outlineVariant': s.outlineVariant,
      'inverseSurface': s.inverseSurface,
      'onInverseSurface': s.onInverseSurface,
      'inversePrimary': s.inversePrimary,
      'shadow': s.shadow,
      'scrim': s.scrim,
      'surfaceTint': s.surfaceTint,
    };

void main() {
  for (final (name, theme) in [('pro', buildProTheme()), ('client', buildClientTheme())]) {
    test('$name theme uses only design tokens for every colour role', () {
      final offenders = <String, Color>{};
      _roles(theme.colorScheme).forEach((role, color) {
        if (!_allowed.contains(color)) offenders[role] = color;
      });

      expect(
        offenders,
        isEmpty,
        reason: 'these roles fell back to a Material default instead of a token: $offenders',
      );
    });

    test('$name nav indicator is neutral, and the accent is on the icon', () {
      final nav = theme.navigationBarTheme;

      // The pill itself carries no accent - a filled accent pill beside
      // accent-filled buttons is the two-accent look this replaced.
      expect(nav.indicatorColor, isNot(RAccent.meter500));
      expect(_allowed, contains(nav.indicatorColor));

      final selectedIcon = nav.iconTheme?.resolve({WidgetState.selected});
      final unselectedIcon = nav.iconTheme?.resolve(<WidgetState>{});
      expect(selectedIcon?.color, RAccent.meter500);
      expect(unselectedIcon?.color, isNot(RAccent.meter500));
    });

    test('$name theme never tints surfaces with the accent', () {
      // M3 tints elevated surfaces with primary. This system uses hairline
      // borders and elevation 0, so a tint would put the accent on surfaces
      // that never asked for one.
      expect(theme.colorScheme.surfaceTint.a, 0);
    });
  }

  test('both apps share one accent', () {
    expect(buildProTheme().colorScheme.primary, buildClientTheme().colorScheme.primary);
    expect(buildProTheme().colorScheme.primary, RAccent.meter500);
  });
}

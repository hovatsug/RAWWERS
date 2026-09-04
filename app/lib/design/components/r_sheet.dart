import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A bottom sheet with the sheet radius token (top corners only) and the
/// one shadow this design system uses outside dialogs/snackbars - it's a
/// genuinely floating, temporary surface.
Future<T?> showRSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    // Without this a sheet is capped at 9/16 of the screen and clips its own
    // content - which put the primary action of the gear and pricing editors
    // below the fold, unreachable, with the keyboard up. Scroll-controlled
    // sheets size to their content instead, and the 0.9 cap keeps the
    // dismissing tap target above them.
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(RRadius.sheet)),
    ),
    builder: builder,
  );
}

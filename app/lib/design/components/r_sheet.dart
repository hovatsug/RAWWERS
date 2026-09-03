import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A bottom sheet with the sheet radius token (top corners only) and the
/// one shadow this design system uses outside dialogs/snackbars - it's a
/// genuinely floating, temporary surface.
Future<T?> showRSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(RRadius.sheet)),
    ),
    builder: builder,
  );
}

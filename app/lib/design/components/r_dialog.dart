import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/tokens.dart';

/// Standard platform dialog presentation (per the motion policy - no custom
/// entrance animation), themed via RCard-equivalent radius/surface tokens.
Future<bool> showRConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.surface)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        RButton(label: confirmLabel, onPressed: () => Navigator.of(context).pop(true)),
      ],
    ),
  );
  return result ?? false;
}

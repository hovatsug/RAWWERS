import 'package:flutter/material.dart';

import '../tokens.dart';

Future<T?> showRBottomSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: RTokens.neutralCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(RTokens.radiusLg)),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          left: RTokens.spacingX4,
          right: RTokens.spacingX4,
          top: RTokens.spacingX4,
          bottom: MediaQuery.viewInsetsOf(context).bottom + RTokens.spacingX4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: RTokens.spacingX3),
            child,
          ],
        ),
      );
    },
  );
}

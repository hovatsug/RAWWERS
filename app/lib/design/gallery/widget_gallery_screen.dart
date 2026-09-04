import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_dialog.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_image_tile.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_progress.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';

// A 1x1 placeholder pixel - the gallery has no real photos to show, and
// pulling one in from the network would make this screen depend on
// connectivity for something that's purely a visual QA tool.
final _placeholderImage = MemoryImage(
  base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII='),
);

/// Debug-only visual QA for every design token and component, in whichever
/// theme it's launched under. Not routed from either app's real navigation
/// - F-5 wires a debug-only entry point to this (e.g. a hidden long-press
/// on a settings row), gated by kDebugMode at the call site.
class RWidgetGalleryScreen extends StatelessWidget {
  const RWidgetGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Design gallery')),
      body: ListView(
        padding: const EdgeInsets.all(RSpace.s16),
        children: [
          _Section(
            title: 'Color',
            child: Wrap(
              spacing: RSpace.s8,
              runSpacing: RSpace.s8,
              children: const [
                _Swatch('ink-950', RInk.i950),
                _Swatch('ink-900', RInk.i900),
                _Swatch('ink-500', RInk.i500),
                _Swatch('ink-050', RInk.i050),
                _Swatch('meter-500', RAccent.meter500),
                _Swatch('meter-700', RAccent.meter700),
                _Swatch('develop-500', RDevelop.develop500),
                _Swatch('shade-600', RShade.shade600),
              ],
            ),
          ),
          _Section(
            title: 'Type',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display 40', style: theme.textTheme.displayLarge),
                Text('Display 28', style: theme.textTheme.displayMedium),
                Text('Display 20', style: theme.textTheme.displaySmall),
                Text('Title 18', style: theme.textTheme.titleLarge),
                Text('Body 15', style: theme.textTheme.bodyLarge),
                Text('Label 13', style: theme.textTheme.labelLarge),
                Text('Caption 11', style: theme.textTheme.bodySmall),
                const SizedBox(height: RSpace.s8),
                Text(
                  '€ 1,234.00 tabular',
                  style: theme.textTheme.bodyLarge?.copyWith(fontFeatures: RType.tabularFigures),
                ),
              ],
            ),
          ),
          _Section(
            title: 'Buttons',
            child: Wrap(
              spacing: RSpace.s12,
              runSpacing: RSpace.s12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                RButton(label: 'Confirm selection', onPressed: () {}),
                const RButton(label: 'Loading', onPressed: null, loading: true),
                RButton(label: 'Decline', onPressed: () {}, variant: RButtonVariant.secondary),
                const RButton(
                  label: 'Loading',
                  onPressed: null,
                  loading: true,
                  variant: RButtonVariant.secondary,
                ),
                RTextLink(label: 'Select all', onPressed: () {}),
              ],
            ),
          ),
          _Section(
            title: 'Filter chips (selectable - not status)',
            child: Wrap(
              spacing: RSpace.s8,
              runSpacing: RSpace.s8,
              children: [
                RFilterChip(label: 'Pending', selected: true, onPressed: () {}),
                RFilterChip(label: 'Accepted', selected: false, onPressed: () {}),
                RFilterChip(label: 'Declined', selected: false, onPressed: () {}),
              ],
            ),
          ),
          _Section(title: 'Input', child: const RInput(label: 'Display name')),
          _Section(
            title: 'Status chips (15 states, 3 signals)',
            child: const Wrap(
              spacing: RSpace.s8,
              runSpacing: RSpace.s8,
              children: [
                RStatusChip(label: 'REQUESTED', kind: RStatusChipKind.inProgress),
                RStatusChip(label: 'AWAITING_SELECTION', kind: RStatusChipKind.inProgress),
                RStatusChip(label: 'DELIVERED', kind: RStatusChipKind.positive),
                RStatusChip(label: 'CLOSED', kind: RStatusChipKind.positive),
                RStatusChip(label: 'CANCELLED', kind: RStatusChipKind.stopped),
                RStatusChip(label: 'DISPUTED', kind: RStatusChipKind.stopped),
              ],
            ),
          ),
          _Section(
            title: 'Card',
            child: RCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Portrait session', style: theme.textTheme.titleLarge),
                  const SizedBox(height: RSpace.s4),
                  Text('10 photos · €240', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          _Section(
            title: 'Progress',
            child: const Column(
              children: [
                RProgressBar(value: 0.62),
                SizedBox(height: RSpace.s8),
                RProgressBar(value: 0.2),
              ],
            ),
          ),
          _Section(
            title: 'Image tiles (sharp corners, selection state)',
            child: Row(
              children: [
                SizedBox(width: 96, height: 96, child: RImageTile(image: _placeholderImage)),
                const SizedBox(width: RSpace.s8),
                SizedBox(
                  width: 96,
                  height: 96,
                  child: RImageTile(image: _placeholderImage, selected: true, onTap: () {}),
                ),
              ],
            ),
          ),
          _Section(title: 'Skeleton', child: const RSkeleton(width: 160, height: 16)),
          _Section(
            title: 'Empty state',
            child: const SizedBox(
              height: 160,
              child: REmptyState(title: 'No bookings yet', body: 'Requests you send will show up here.'),
            ),
          ),
          _Section(
            title: 'Error state',
            child: SizedBox(
              height: 160,
              child: RErrorState(message: "Couldn't load this page.", onRetry: () {}),
            ),
          ),
          _Section(
            title: 'Dialog / sheet',
            child: Wrap(
              spacing: RSpace.s12,
              children: [
                RButton(
                  label: 'Show dialog',
                  onPressed: () => showRConfirmDialog(context, title: 'Cancel booking?', message: 'This cannot be undone.'),
                ),
                RButton(
                  label: 'Show sheet',
                  onPressed: () => showRSheet<void>(
                    context,
                    builder: (context) => const Padding(
                      padding: EdgeInsets.all(RSpace.s24),
                      child: Text('Sheet content'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: RSpace.s32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: RSpace.s12),
          child,
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(RRadius.surface),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(height: RSpace.s4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

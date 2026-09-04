import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/gear_category.dart';
import 'package:rawwers/api/models/gear_item_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_dialog.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/gear/gear_controller.dart';

class GearScreen extends ConsumerWidget {
  const GearScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gear = ref.watch(gearControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your kit')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: switch (gear) {
          AsyncData(:final value) when value.isEmpty => const _EmptyKit(),
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(gearControllerProvider),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s16, RSpace.s16, RSpace.s64),
                itemCount: value.length,
                separatorBuilder: (_, _) => const SizedBox(height: RSpace.s12),
                itemBuilder: (context, index) => _GearRow(
                  item: value[index],
                  onEdit: () => _openEditor(context, ref, existing: value[index]),
                  onRemove: () => _confirmRemove(context, ref, value[index]),
                ),
              ),
            ),
          AsyncError() => RErrorState(
              message: 'Could not load your kit.',
              onRetry: () => ref.invalidate(gearControllerProvider),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [RSkeleton(width: 220), SizedBox(height: RSpace.s16), RSkeleton(width: 180)],
              ),
            ),
        },
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref, {GearItemView? existing}) async {
    await showRSheet<void>(
      context,
      builder: (context) => Padding(
        // The keyboard is up the whole time this sheet is open.
        padding: EdgeInsets.only(
          left: RSpace.s16,
          right: RSpace.s16,
          top: RSpace.s24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + RSpace.s24,
        ),
        child: SingleChildScrollView(child: _GearEditor(existing: existing)),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref, GearItemView item) async {
    final name = [item.brand, item.model].whereType<String>().join(' ');
    final confirmed = await showRConfirmDialog(
      context,
      title: 'Remove this item?',
      message: name.isEmpty
          ? 'It will be taken off your kit list.'
          : '$name will be taken off your kit list.',
      confirmLabel: 'Remove',
    );
    if (!confirmed || !context.mounted) return;

    final error = await ref.read(gearControllerProvider.notifier).remove(item.id);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _EmptyKit extends StatelessWidget {
  const _EmptyKit();

  @override
  Widget build(BuildContext context) {
    return const REmptyState(
      icon: Icons.camera_alt_outlined,
      title: 'No kit listed yet',
      // The reason is the point: without it this reads as busywork.
      body: 'Recording serial numbers now is what makes a stolen or '
          'damaged body straightforward to claim for later.',
    );
  }
}

class _GearRow extends StatelessWidget {
  const _GearRow({required this.item, required this.onEdit, required this.onRemove});

  final GearItemView item;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = [item.brand, item.model].whereType<String>().join(' ');

    return RCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? gearCategoryLabel(item.category) : name, style: theme.textTheme.titleSmall),
                const SizedBox(height: RSpace.s4),
                Text(gearCategoryLabel(item.category), style: theme.textTheme.bodySmall),
                if (item.serialNumber != null) ...[
                  const SizedBox(height: RSpace.s4),
                  Text('Serial ${item.serialNumber}', style: theme.textTheme.bodySmall),
                ],
                if (item.notes != null) ...[
                  const SizedBox(height: RSpace.s8),
                  Text(item.notes!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined), tooltip: 'Edit'),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline), tooltip: 'Remove'),
        ],
      ),
    );
  }
}

class _GearEditor extends ConsumerStatefulWidget {
  const _GearEditor({this.existing});

  final GearItemView? existing;

  @override
  ConsumerState<_GearEditor> createState() => _GearEditorState();
}

class _GearEditorState extends ConsumerState<_GearEditor> {
  late final TextEditingController _brand;
  late final TextEditingController _model;
  late final TextEditingController _serial;
  late final TextEditingController _notes;
  late GearCategory _category;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _brand = TextEditingController(text: e?.brand ?? '');
    _model = TextEditingController(text: e?.model ?? '');
    _serial = TextEditingController(text: e?.serialNumber ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _category = e?.category ?? GearCategory.cameraBody;
  }

  @override
  void dispose() {
    for (final c in [_brand, _model, _serial, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final notifier = ref.read(gearControllerProvider.notifier);
    final existing = widget.existing;
    final error = existing == null
        ? await notifier.add(
            category: _category,
            brand: _brand.text,
            model: _model.text,
            serialNumber: _serial.text,
            notes: _notes.text,
          )
        : await notifier.edit(
            id: existing.id,
            category: _category,
            brand: _brand.text,
            model: _model.text,
            serialNumber: _serial.text,
            notes: _notes.text,
          );

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<GearCategory>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            for (final category in GearCategory.values)
              DropdownMenuItem(value: category, child: Text(gearCategoryLabel(category))),
          ],
          onChanged: (value) => setState(() => _category = value ?? _category),
        ),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'Make', controller: _brand),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'Model', controller: _model),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'Serial number', controller: _serial),
        Padding(
          padding: const EdgeInsets.only(top: RSpace.s4),
          child: Text('Worth the two minutes now.', style: theme.textTheme.bodySmall),
        ),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'Notes', controller: _notes, maxLines: 3),
        const SizedBox(height: RSpace.s24),
        if (_error != null) ...[
          Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: RSpace.s12),
        ],
        RButton(
          label: widget.existing == null ? 'Add to kit' : 'Save',
          onPressed: _saving ? null : _submit,
          loading: _saving,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/pro_niche_pricing_preview_response.dart';
import 'package:rawwers/api/models/pro_package_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/portfolio/niches_controller.dart';
import 'package:rawwers/features/pro/pricing/pricing_controller.dart';

/// What the pro charges, per niche.
///
/// The decay curve is the entire argument for this pricing model, and it
/// is not something a photographer can hold in their head from a formula.
/// So the editor shows what a client actually pays at real photo counts,
/// recomputed from the server as the entry price is typed - not a
/// client-side approximation that could disagree with the invoice.
class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = ref.watch(packagesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pricing')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add a package'),
      ),
      body: SafeArea(
        child: switch (packages) {
          AsyncData(:final value) when value.isEmpty => const _NoPackages(),
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(packagesControllerProvider),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s16, RSpace.s16, RSpace.s64),
                itemCount: value.length,
                separatorBuilder: (_, _) => const SizedBox(height: RSpace.s12),
                itemBuilder: (context, index) => _PackageRow(
                  package: value[index],
                  onEdit: () => _openEditor(context, existing: value[index]),
                ),
              ),
            ),
          AsyncError() => RErrorState(
              message: 'Could not load your pricing.',
              onRetry: () => ref.invalidate(packagesControllerProvider),
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

  Future<void> _openEditor(BuildContext context, {ProPackageView? existing}) async {
    await showRSheet<void>(
      context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: RSpace.s16,
          right: RSpace.s16,
          top: RSpace.s24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + RSpace.s24,
        ),
        child: SingleChildScrollView(child: _PackageEditor(existing: existing)),
      ),
    );
  }
}

class _NoPackages extends StatelessWidget {
  const _NoPackages();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(RSpace.s32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sell_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: RSpace.s16),
          Text('No pricing set', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s8),
          Text(
            'A client cannot book you until you have priced at least one '
            'kind of shoot.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PackageRow extends ConsumerWidget {
  const _PackageRow({required this.package, required this.onEdit});

  final ProPackageView package;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return RCard(
      child: InkWell(
        onTap: onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(package.title, style: theme.textTheme.titleSmall)),
                if (!package.isActive)
                  const RStatusChip(label: 'Off', kind: RStatusChipKind.inProgress),
              ],
            ),
            const SizedBox(height: RSpace.s8),
            // The per-photo rate is the number the curve is built from;
            // the bundle total is what a client sees first.
            Text(
              '${package.currency} ${package.price} per photo · '
              '${package.includedPhotos} included',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: RSpace.s4),
            Text('${package.durationMinutes} minutes', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PackageEditor extends ConsumerStatefulWidget {
  const _PackageEditor({this.existing});

  final ProPackageView? existing;

  @override
  ConsumerState<_PackageEditor> createState() => _PackageEditorState();
}

class _PackageEditorState extends ConsumerState<_PackageEditor> {
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _included;
  late final TextEditingController _extra;
  late final TextEditingController _duration;

  String? _nicheSlug;
  String? _nicheId;
  bool _saving = false;
  String? _error;

  /// The price the curve is currently drawn for. Updated on submit of the
  /// field rather than on every keystroke: each change is a server call,
  /// and redrawing the curve mid-number would show a photographer the
  /// price of "1" on the way to typing "12".
  String _previewPrice = '';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _price = TextEditingController(text: e?.price ?? '');
    _included = TextEditingController(text: (e?.includedPhotos ?? 10).toString());
    _extra = TextEditingController(text: e?.extraPhotoPrice ?? '');
    _duration = TextEditingController(text: (e?.durationMinutes ?? 60).toString());
    _previewPrice = e?.price ?? '';
    _nicheId = e?.nicheId;
  }

  @override
  void dispose() {
    for (final c in [_title, _price, _included, _extra, _duration]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final slug = _nicheSlug;
    if (slug == null) {
      setState(() => _error = 'Pick what kind of shoot this is.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final message = await ref.read(packagesControllerProvider.notifier).createOrUpdate(
          packageId: widget.existing?.id,
          nicheSlug: slug,
          title: _title.text.trim(),
          price: _price.text.trim(),
          includedPhotos: int.tryParse(_included.text.trim()) ?? 10,
          extraPhotoPrice: _extra.text.trim().isEmpty ? _price.text.trim() : _extra.text.trim(),
          durationMinutes: int.tryParse(_duration.text.trim()) ?? 60,
        );

    if (!mounted) return;
    if (message == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final niches = ref.watch(nichesControllerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.existing == null ? 'New package' : 'Edit package',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'What you call it', controller: _title),
        const SizedBox(height: RSpace.s16),
        Text('What kind of shoot', style: theme.textTheme.bodyMedium),
        const SizedBox(height: RSpace.s8),
        switch (niches) {
          AsyncData(:final value) => Wrap(
              spacing: RSpace.s8,
              runSpacing: RSpace.s8,
              children: [
                for (final niche in value)
                  RSelectableChip(
                    label: niche.name,
                    selected: _nicheSlug == niche.slug,
                    onPressed: () => setState(() {
                      _nicheSlug = niche.slug;
                      _nicheId = niche.id;
                    }),
                  ),
              ],
            ),
          AsyncError() => const Text('Could not load the list of shoot types.'),
          _ => const RSkeleton(width: 200),
        },
        const SizedBox(height: RSpace.s16),
        RInput(
          label: 'Price per photo',
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => setState(() => _previewPrice = value.trim()),
        ),
        Padding(
          padding: const EdgeInsets.only(top: RSpace.s4),
          child: Text(
            'The first 10 photos always cost this each. Beyond that the '
            'per-photo price tapers.',
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: RSpace.s16),
        _CurvePreview(nicheId: _nicheId, nicheSlug: _nicheSlug, entryPrice: _previewPrice),
        const SizedBox(height: RSpace.s16),
        Row(
          children: [
            Expanded(child: RInput(label: 'Photos included', controller: _included, keyboardType: TextInputType.number)),
            const SizedBox(width: RSpace.s12),
            Expanded(child: RInput(label: 'Minutes', controller: _duration, keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: RSpace.s24),
        if (_error != null) ...[
          Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: RSpace.s12),
        ],
        RButton(label: 'Save', onPressed: _saving ? null : _save, loading: _saving),
      ],
    );
  }
}

/// The decay curve, from the server.
///
/// Deliberately not computed here. The same numbers appear on the client's
/// invoice, and a client-side approximation that rounded differently would
/// be a photographer quoting one price and the platform charging another.
class _CurvePreview extends ConsumerWidget {
  const _CurvePreview({required this.nicheId, required this.nicheSlug, required this.entryPrice});

  final String? nicheId;
  final String? nicheSlug;
  final String entryPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (nicheId == null || entryPrice.isEmpty) {
      return RCard(
        child: Text(
          'Pick a shoot type and enter a price to see what a client pays.',
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    final preview = ref.watch(pricingPreviewProvider(nicheId: nicheId!, entryPrice: entryPrice));

    return switch (preview) {
      AsyncData(:final value) => _CurveTable(preview: value),
      AsyncError() => RCard(
          child: Text('Could not work out the price.', style: theme.textTheme.bodySmall),
        ),
      _ => const RCard(child: RSkeleton(width: 200)),
    };
  }

}

class _CurveTable extends StatelessWidget {
  const _CurveTable({required this.preview});

  final ProNichePricingPreviewResponse preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = preview.currency;

    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What a client pays', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s12),
          for (final point in preview.curve ?? const [])
            Padding(
              padding: const EdgeInsets.only(bottom: RSpace.s8),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text('${point.photoCount} photos', style: theme.textTheme.bodySmall),
                  ),
                  Expanded(
                    child: Text(
                      '$currency ${point.total}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ),
                  Text(
                    '$currency ${point.perPhoto} each',
                    style: theme.textTheme.bodySmall?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
            ),
          if (!preview.withinCap) ...[
            const Divider(height: RSpace.s24),
            Text(
              _capMessage(preview),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  /// Named limits, not "invalid": a photographer over the cap needs to know
  /// what number would work, while they are still typing.
  String _capMessage(ProNichePricingPreviewResponse preview) {
    final max = preview.entryPriceMax;
    if (max != null) {
      return 'At your current tier this niche is capped at ${preview.currency} $max per photo. '
          'Saving will be refused above that.';
    }
    return 'The minimum for this niche at your tier is ${preview.currency} ${preview.entryPriceMin} per photo.';
  }
}

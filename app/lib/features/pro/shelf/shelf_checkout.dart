import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/shelf_address.dart';
import 'package:rawwers/api/models/shelf_browse_item.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/shelf/shelf_orders_controller.dart';

/// Opens the checkout for one item: the address it ships to (saved once,
/// editable), what it costs and what is left after, and Place order.
/// Returns true when an order was placed.
Future<bool> showShelfCheckout(BuildContext context, {required ShelfBrowseItem item, required int spendable}) async {
  final placed = await showRSheet<bool>(
    context,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(RSpace.s16),
        child: ShelfCheckout(item: item, spendable: spendable),
      ),
    ),
  );
  return placed ?? false;
}

class ShelfCheckout extends ConsumerStatefulWidget {
  const ShelfCheckout({required this.item, required this.spendable, super.key});

  final ShelfBrowseItem item;
  final int spendable;

  @override
  ConsumerState<ShelfCheckout> createState() => _ShelfCheckoutState();
}

class _ShelfCheckoutState extends ConsumerState<ShelfCheckout> {
  /// One id for every tap on this sheet: two taps are one order.
  final String _requestId = newOrderRequestId();
  final _name = TextEditingController();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _postcode = TextEditingController();
  bool _editing = false;
  bool _filled = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _line1, _line2, _city, _postcode]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(ShelfAddress? address) {
    if (_filled) return;
    _filled = true;
    _name.text = address?.name ?? '';
    _line1.text = address?.line1 ?? '';
    _line2.text = address?.line2 ?? '';
    _city.text = address?.city ?? '';
    _postcode.text = address?.postalCode ?? '';
    _editing = address == null;
  }

  Future<void> _place(String country) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    if (_editing) {
      final problem = await ref.read(shelfAddressControllerProvider.notifier).save(
            ShelfAddress(
              name: _name.text,
              line1: _line1.text,
              line2: _line2.text,
              city: _city.text,
              postalCode: _postcode.text,
              country: country,
            ),
          );
      if (!mounted) return;
      if (problem != null) {
        setState(() {
          _busy = false;
          _error = problem;
        });
        return;
      }
    }
    final problem = await ref.read(shelfOrdersControllerProvider.notifier).place(itemId: widget.item.id, requestId: _requestId);
    if (!mounted) return;
    if (problem == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _error = problem;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final addressState = ref.watch(shelfAddressControllerProvider);
    final address = addressState.valueOrNull;
    if (address == null) {
      return addressState.hasError
          ? Text('The address could not be loaded. Try again.', style: theme.textTheme.bodyMedium)
          : const Padding(padding: EdgeInsets.all(RSpace.s24), child: Center(child: CircularProgressIndicator()));
    }
    _fill(address.address);
    final country = address.allowedCountries.first;
    final saved = address.address;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.item.title, style: theme.textTheme.titleMedium),
        const SizedBox(height: RSpace.s8),
        Text('${widget.item.priceRaww} RAWW', style: theme.textTheme.headlineSmall),
        Text('${widget.spendable - widget.item.priceRaww} RAWW left after this order. Free shipping.', style: muted),
        const SizedBox(height: RSpace.s16),
        Text('Ships to', style: theme.textTheme.titleSmall),
        const SizedBox(height: RSpace.s8),
        if (!_editing && saved != null) ...[
          Text(
            [saved.name, saved.line1, saved.line2, saved.city, saved.postalCode, saved.country].whereType<String>().where((s) => s.isNotEmpty).join('\n'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: () => setState(() => _editing = true), child: const Text('Change address')),
          ),
        ] else ...[
          RInput(label: 'Name', controller: _name),
          const SizedBox(height: RSpace.s12),
          RInput(label: 'Address', controller: _line1),
          const SizedBox(height: RSpace.s12),
          RInput(label: 'Address line 2 (optional)', controller: _line2),
          const SizedBox(height: RSpace.s12),
          RInput(label: 'Town or city', controller: _city),
          const SizedBox(height: RSpace.s12),
          RInput(label: 'Postcode', controller: _postcode),
          Padding(
            padding: const EdgeInsets.only(top: RSpace.s4),
            child: Text('The Shelf ships to ${address.allowedCountries.join(', ')} for now.', style: muted),
          ),
        ],
        const SizedBox(height: RSpace.s16),
        if (_error != null) ...[
          Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: RSpace.s12),
        ],
        RButton(label: 'Place order', loading: _busy, onPressed: _busy ? null : () => _place(country)),
        const SizedBox(height: RSpace.s8),
        Text('You can cancel it until we order it from the supplier; your RAWW come back at once.', style: muted),
      ],
    );
  }
}

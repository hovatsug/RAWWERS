import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/profile/profile_editor_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

/// Everything a client reads before deciding whether to send a request.
///
/// Ordered by what a client looks at first, not by what is cheapest to
/// collect: the name and the one-line headline sit at the top because they
/// are the whole card in Discover.
class ProProfileEditScreen extends ConsumerWidget {
  const ProProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(proProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your profile')),
      body: SafeArea(
        child: switch (profile) {
          AsyncData(:final value) => _Form(profile: value),
          AsyncError() => RErrorState(
              message: 'Could not load your profile.',
              onRetry: () => ref.invalidate(proProfileControllerProvider),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RSkeleton(width: 200),
                  SizedBox(height: RSpace.s16),
                  RSkeleton(width: 280),
                  SizedBox(height: RSpace.s16),
                  RSkeleton(width: 240),
                ],
              ),
            ),
        },
      ),
    );
  }
}

/// Offered as chips rather than free text: a client filtering on "editorial"
/// finds nobody who typed "Editorial " with a trailing space, and a pro has
/// no way to discover which spelling wins.
const _styleOptions = [
  'Editorial', 'Documentary', 'Portrait', 'Fine art', 'Candid',
  'Studio', 'Natural light', 'Black and white', 'Film',
];

const _languageOptions = [
  'English', 'Portuguese', 'Spanish', 'French', 'German', 'Italian',
];

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.profile});

  final ProProfileView profile;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  late final TextEditingController _name;
  late final TextEditingController _headline;
  late final TextEditingController _bio;
  late final TextEditingController _city;
  late final TextEditingController _country;
  late final TextEditingController _radius;
  late Set<String> _styles;
  late Set<String> _languages;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.displayName ?? '');
    _headline = TextEditingController(text: p.headline ?? '');
    _bio = TextEditingController(text: p.bio ?? '');
    _city = TextEditingController(text: p.city ?? '');
    _country = TextEditingController(text: p.country ?? '');
    // Empty rather than "0": the profile distinguishes "has not said" from
    // "will not travel", and prefilling a zero would answer for them.
    _radius = TextEditingController(text: p.travelRadiusKm?.toString() ?? '');
    _styles = {...?p.styles};
    _languages = {...?p.languages};
  }

  @override
  void dispose() {
    for (final c in [_name, _headline, _bio, _city, _country, _radius]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final radiusText = _radius.text.trim();
    final radius = radiusText.isEmpty ? null : int.tryParse(radiusText);
    if (radiusText.isNotEmpty && (radius == null || radius < 0)) {
      setState(() => _error = 'Travel radius should be a number of kilometres.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final message = await ref.read(profileEditorControllerProvider.notifier).save(
          current: widget.profile,
          displayName: _name.text,
          headline: _headline.text,
          bio: _bio.text,
          city: _city.text,
          country: _country.text,
          travelRadiusKm: radius,
          languages: _languages.toList(),
          styles: _styles.toList(),
        );

    if (!mounted) return;
    setState(() {
      _saving = false;
      _error = message;
    });
    if (message == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(RSpace.s16),
      children: [
        RInput(label: 'Display name', controller: _name),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'Headline', controller: _headline),
        Padding(
          padding: const EdgeInsets.only(top: RSpace.s4),
          child: Text(
            'One line, shown under your name on the card a client sees first.',
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'About you', controller: _bio, maxLines: 5),
        const SizedBox(height: RSpace.s24),

        Text('Where you work', style: theme.textTheme.titleMedium),
        const SizedBox(height: RSpace.s12),
        RInput(label: 'City', controller: _city),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'Country', controller: _country),
        const SizedBox(height: RSpace.s16),
        RInput(label: 'Travel radius (km)', controller: _radius, keyboardType: TextInputType.number),
        Padding(
          padding: const EdgeInsets.only(top: RSpace.s4),
          child: Text(
            'How far you will travel for a shoot. Leave empty if you would '
            'rather talk about it per booking.',
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: RSpace.s24),

        Text('How you shoot', style: theme.textTheme.titleMedium),
        const SizedBox(height: RSpace.s12),
        _ChipPicker(
          options: _styleOptions,
          selected: _styles,
          onToggle: (value) => setState(() => _styles.toggle(value)),
        ),
        const SizedBox(height: RSpace.s24),

        Text('Languages', style: theme.textTheme.titleMedium),
        const SizedBox(height: RSpace.s12),
        _ChipPicker(
          options: _languageOptions,
          selected: _languages,
          onToggle: (value) => setState(() => _languages.toggle(value)),
        ),
        const SizedBox(height: RSpace.s32),

        if (_error != null) ...[
          Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: RSpace.s12),
        ],
        RButton(label: 'Save', onPressed: _saving ? null : _save, loading: _saving),
      ],
    );
  }
}

extension _Toggle on Set<String> {
  void toggle(String value) => contains(value) ? remove(value) : add(value);
}

class _ChipPicker extends StatelessWidget {
  const _ChipPicker({required this.options, required this.selected, required this.onToggle});

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: RSpace.s8,
      runSpacing: RSpace.s8,
      children: [
        for (final option in options)
          RSelectableChip(
            label: option,
            selected: selected.contains(option),
            onPressed: () => onToggle(option),
          ),
      ],
    );
  }
}

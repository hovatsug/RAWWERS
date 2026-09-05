import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_waitlist_create_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/features/client/discover/location_controller.dart';

/// Asks where the client is looking, and checks we actually operate there.
///
/// This is entry-then-check rather than pick-from-a-list because there is no
/// public endpoint listing enabled cities - `/v1/admin/rollout/cities` is
/// admin-only. It is nonetheless the flow the API is built for:
/// `GET /v1/client/access` answers "are we live here", and
/// `waitlist_available` plus `POST /v1/client/waitlist` covers the no case,
/// so somewhere we haven't launched is a real answer rather than an error.
class LocationPrompt extends ConsumerStatefulWidget {
  const LocationPrompt({super.key});

  @override
  ConsumerState<LocationPrompt> createState() => _LocationPromptState();
}

class _LocationPromptState extends ConsumerState<LocationPrompt> {
  final _city = TextEditingController();
  final _country = TextEditingController();
  String? _error;
  bool _busy = false;

  /// Set when we're live in the entered place but something else failed, or
  /// when we're not live there and a waitlist is offered.
  String? _waitlistCity;

  @override
  void dispose() {
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final city = _city.text.trim();
    final country = _country.text.trim().toUpperCase();
    if (city.isEmpty || country.length != 2) {
      setState(() => _error = 'Enter a city and a two-letter country code, like PT.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _waitlistCity = null;
    });

    final client = ref.read(clientLaunchClientProvider);
    final access = await apiCall(
      () => client.getClientAccessV1ClientAccessGet(
        country: country,
        city: city,
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );

    if (!mounted) return;

    switch (access) {
      case Err():
        setState(() {
          _busy = false;
          _error = 'Could not check that location. Check your connection and try again.';
        });
      case Ok(:final value):
        if (!value.enabled) {
          setState(() {
            _busy = false;
            _waitlistCity = value.waitlistAvailable ? city : null;
            _error = value.waitlistAvailable
                ? 'We\'re not in $city yet.'
                : 'We\'re not in $city yet, and there\'s no waitlist for it right now.';
          });
          return;
        }
        final saveError = await ref
            .read(locationControllerProvider.notifier)
            .setLocation(BrowseLocation(country: country, city: city));
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = saveError;
        });
    }
  }

  Future<void> _joinWaitlist() async {
    // The waitlist needs a real address to be worth anything - it exists so
    // someone can be told when we arrive. Taken from the signed-in account
    // rather than asked for again, and the button is not offered at all if
    // we somehow don't have one.
    final email = switch (ref.read(authControllerProvider).valueOrNull) {
      AuthAuthenticated(:final me) => me.email,
      _ => null,
    };
    if (email == null || email.isEmpty) {
      setState(() => _error = 'We need an email on your account to add you to the waitlist.');
      return;
    }

    setState(() => _busy = true);
    final client = ref.read(clientLaunchClientProvider);
    final city = _city.text.trim();
    final result = await apiCall(
      () => client.createWaitlistEntryV1ClientWaitlistPost(
        requestBody: ClientWaitlistCreateRequest(
          email: email,
          country: _country.text.trim().toUpperCase(),
          city: city,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case Ok():
          _waitlistCity = null;
          _error = 'Thanks - we\'ll let you know when we reach $city.';
        case Err():
          _error = 'Could not add you to the waitlist. Try again in a moment.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where are you looking?', style: theme.textTheme.headlineSmall),
          const SizedBox(height: RSpace.s8),
          Text(
            'Photographers are listed by city, so we need to know where your shoot is.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RSpace.s24),
          RInput(label: 'City', controller: _city, autofillHints: const [AutofillHints.addressCity]),
          const SizedBox(height: RSpace.s12),
          RInput(
            label: 'Country code (e.g. PT)',
            controller: _country,
            autofillHints: const [AutofillHints.countryCode],
          ),
          if (_error != null) ...[
            const SizedBox(height: RSpace.s12),
            Text(_error!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: RSpace.s24),
          if (_waitlistCity != null)
            RButton(label: 'Tell me when you\'re in $_waitlistCity', loading: _busy, onPressed: _busy ? null : _joinWaitlist)
          else
            RButton(label: 'Continue', loading: _busy, onPressed: _busy ? null : _submit),
        ],
      ),
    );
  }
}

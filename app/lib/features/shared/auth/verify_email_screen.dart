import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/verify_email_confirm_request.dart';
import 'package:rawwers/api/models/verify_email_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';

/// Verifying email doesn't gate access to anything (checked against the
/// real backend - no dependency requires email_verified_at), so this is
/// reachable from Account/Settings whenever, not a forced step in
/// onboarding.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  String? _error;
  String? _status;
  bool _submitting = false;
  bool _sending = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final me = switch (ref.read(authControllerProvider).valueOrNull) {
      AuthAuthenticated(:final me) => me,
      _ => null,
    };
    if (me?.email == null) return;

    setState(() => _sending = true);
    final client = ref.read(authClientProvider);
    await apiCall(
      () => client.verifyEmailRequestV1AuthVerifyEmailRequestPost(requestBody: VerifyEmailRequest(email: me!.email!)),
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _status = 'Code sent to ${me!.email}.';
    });
  }

  Future<void> _confirm() async {
    final code = _code.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter the code from your email.');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    final client = ref.read(authClientProvider);
    final result = await apiCall(
      () => client.verifyEmailConfirmV1AuthVerifyEmailConfirmPost(requestBody: VerifyEmailConfirmRequest(code: code)),
    );

    if (!mounted) return;
    switch (result) {
      case Ok():
        setState(() {
          _status = 'Email verified.';
          _submitting = false;
        });
      case Err():
        setState(() {
          _error = 'That code is invalid or has expired.';
          _submitting = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify email')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Confirming your email helps us reach you about your bookings.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: RSpace.s16),
              RTextLink(label: 'Send me a code', onPressed: _sending ? () {} : _sendCode),
              const SizedBox(height: RSpace.s16),
              RInput(
                label: 'Code',
                controller: _code,
                keyboardType: TextInputType.number,
                // Lets iOS surface the emailed code straight from the
                // keyboard bar instead of making the user switch apps.
                autofillHints: const [AutofillHints.oneTimeCode],
              ),
              if (_error != null) ...[
                const SizedBox(height: RSpace.s12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              if (_status != null) ...[
                const SizedBox(height: RSpace.s12),
                Text(_status!, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: RSpace.s24),
              RButton(label: 'Confirm', onPressed: _submitting ? null : _confirm, loading: _submitting),
            ],
          ),
        ),
      ),
    );
  }
}

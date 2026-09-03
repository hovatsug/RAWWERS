import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/api/models/password_reset_request.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({required this.resetPasswordPath, super.key});

  final String resetPasswordPath;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _error;
  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    final client = ref.read(authClientProvider);
    // Result intentionally unused below: always show success, even on
    // failure - confirming or denying that an email exists in the system
    // is an account-enumeration leak.
    await apiCall(
      () => client.passwordResetRequestV1AuthPasswordResetRequestPost(requestBody: PasswordResetRequest(email: email)),
    );

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_sent) ...[
                Text(
                  "If that email has an account, we've sent a code to reset the password.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: RSpace.s16),
                RButton(
                  label: 'Enter code',
                  onPressed: () => context.go(widget.resetPasswordPath),
                ),
              ] else ...[
                Text('Enter your email and we\'ll send you a code to reset your password.'),
                const SizedBox(height: RSpace.s16),
                RInput(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress),
                if (_error != null) ...[
                  const SizedBox(height: RSpace.s12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: RSpace.s24),
                RButton(label: 'Send code', onPressed: _submitting ? null : _submit, loading: _submitting),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({required this.loginPath, super.key});

  final String loginPath;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    final error = await ref.read(authControllerProvider.notifier).register(email: email, password: password);

    if (!mounted) return;
    setState(() {
      _error = error;
      _submitting = false;
    });
    // On success (error == null) the router's redirect reacts to the auth
    // state change on its own - no explicit navigation here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // `newPassword` is the hint that makes the OS offer to save a
              // generated password; `password` would only offer to fill an
              // existing one, which is the wrong prompt on a sign-up form.
              // Without any hint iOS guesses, and it offered an Apple ID here.
              AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RInput(
                      label: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: RSpace.s12),
                    RInput(
                      label: 'Password',
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (!_submitting) _submit();
                      },
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: RSpace.s12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: RSpace.s24),
              RButton(label: 'Create account', onPressed: _submitting ? null : _submit, loading: _submitting),
              const SizedBox(height: RSpace.s16),
              RTextLink(label: 'Already have an account? Log in', onPressed: () => context.go(widget.loginPath)),
            ],
          ),
        ),
      ),
    );
  }
}

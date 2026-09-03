import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({required this.registerPath, required this.forgotPasswordPath, super.key});

  final String registerPath;
  final String forgotPasswordPath;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    final error = await ref.read(authControllerProvider.notifier).login(email: email, password: password);

    if (!mounted) return;
    setState(() {
      _error = error;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Carries a message through from a register-succeeded-but-login-failed
    // split (see AuthController.register) - shown once, here, regardless
    // of how the user arrived at this screen.
    final carriedMessage = switch (ref.read(authControllerProvider).valueOrNull) {
      AuthUnauthenticated(:final message) => message,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (carriedMessage != null) ...[
                Text(carriedMessage, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: RSpace.s16),
              ],
              RInput(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: RSpace.s12),
              RInput(label: 'Password', controller: _password, obscureText: true),
              if (_error != null) ...[
                const SizedBox(height: RSpace.s12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: RSpace.s8),
              Align(
                alignment: Alignment.centerRight,
                child: RTextLink(
                  label: 'Forgot password?',
                  onPressed: () => context.go(widget.forgotPasswordPath),
                ),
              ),
              const SizedBox(height: RSpace.s16),
              RButton(label: 'Log in', onPressed: _submitting ? null : _submit, loading: _submitting),
              const SizedBox(height: RSpace.s16),
              RTextLink(label: "Don't have an account? Create one", onPressed: () => context.go(widget.registerPath)),
            ],
          ),
        ),
      ),
    );
  }
}

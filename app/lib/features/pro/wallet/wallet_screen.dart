import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_empty_state.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: const REmptyState(title: 'Wallet comes in F-6'),
    );
  }
}

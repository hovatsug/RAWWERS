import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_empty_state.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: const REmptyState(title: 'Bookings comes in F-7'),
    );
  }
}

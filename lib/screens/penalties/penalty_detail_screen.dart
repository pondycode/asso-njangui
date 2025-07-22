import 'package:flutter/material.dart';

class PenaltyDetailScreen extends StatelessWidget {
  final String penaltyId;

  const PenaltyDetailScreen({super.key, required this.penaltyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penalty Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Penalty Detail Screen - Coming Soon'),
      ),
    );
  }
}

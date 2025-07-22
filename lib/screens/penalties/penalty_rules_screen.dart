import 'package:flutter/material.dart';

class PenaltyRulesScreen extends StatelessWidget {
  const PenaltyRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penalty Rules'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Penalty Rules Screen - Coming Soon'),
      ),
    );
  }
}

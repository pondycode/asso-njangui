import 'package:flutter/material.dart';

class ApplyPenaltyScreen extends StatelessWidget {
  final String? memberId;

  const ApplyPenaltyScreen({super.key, this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Penalty'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Apply Penalty Screen - Coming Soon'),
      ),
    );
  }
}

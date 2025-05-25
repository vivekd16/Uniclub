import 'package:flutter/material.dart';

class ClubDashboard extends StatelessWidget {
  const ClubDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Club Admin Dashboard')),
      body: const Center(child: Text('Welcome, Club Admin')),
    );
  }
}

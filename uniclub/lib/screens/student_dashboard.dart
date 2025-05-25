import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('🔍 Discover Clubs by Category/Interest'),
          SizedBox(height: 10),
          Text('📅 Upcoming Events'),
          SizedBox(height: 10),
          Text('👥 Your Joined Clubs'),
          SizedBox(height: 10),
          Text('📰 Activity Feed'),
          SizedBox(height: 10),
          Text('💬 Chat with Club Members'),
        ],
      ),
    );
  }
}

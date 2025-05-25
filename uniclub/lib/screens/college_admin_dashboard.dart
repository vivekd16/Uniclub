import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CollegeAdminDashboard extends StatefulWidget {
  const CollegeAdminDashboard({super.key});

  @override
  State<CollegeAdminDashboard> createState() => _CollegeAdminDashboardState();
}

class _CollegeAdminDashboardState extends State<CollegeAdminDashboard> {
  String? _collegeId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCollegeId();
  }

  Future<void> _loadCollegeId() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _collegeId = doc.data()?['collegeId'];
      _loading = false;
    });
  }

  Stream<QuerySnapshot> _getCollegeClubs() {
    return FirebaseFirestore.instance
        .collection('clubs')
        .where('collegeId', isEqualTo: _collegeId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('College Admin Dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Club'),
                    onPressed: () => Navigator.pushNamed(context, '/create-club'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Your College Clubs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getCollegeClubs(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('No clubs created yet.'));
                      }
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(backgroundImage: NetworkImage(data['logoUrl'] ?? '')),
                            title: Text(data['name'] ?? ''),
                            subtitle: Text(data['category'] ?? ''),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

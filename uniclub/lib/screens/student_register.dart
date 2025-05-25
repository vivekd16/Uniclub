import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _studentId = TextEditingController();
  final _department = TextEditingController();
  int _year = 1;

  Map<String, dynamic>? _selectedCollege;
  List<Map<String, dynamic>> _colleges = [];

  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('colleges').get();

      final collegeList = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'domain': data['domain'],
        };
      }).toList();

      setState(() {
        _colleges = collegeList;
        _selectedCollege = _colleges.isNotEmpty ? _colleges[0] : null;
      });
    } catch (e) {
      setState(() => _error = 'Failed to load colleges: $e');
    }
  }

  Future<void> _registerStudent() async {
    final email = _email.text.trim();
    final password = _password.text;
    final name = _name.text.trim();
    final studentId = _studentId.text.trim();
    final department = _department.text.trim();

    if (_selectedCollege == null) {
      setState(() => _error = 'Please select a college');
      return;
    }

    if (!email.endsWith('@${_selectedCollege!['domain']}')) {
      setState(() => _error = 'Email must be from ${_selectedCollege!['domain']}');
      return;
    }

    if ([email, password, name, studentId, department].any((e) => e.isEmpty)) {
      setState(() => _error = 'All fields are required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'student',
        'email': email,
        'name': name,
        'studentId': studentId,
        'course': department,
        'year': _year,
        'collegeId': _selectedCollege!['id'],
      });

      await userCred.user!.sendEmailVerification();

      Navigator.pushReplacementNamed(context, '/verify-email');
    } catch (e) {
      setState(() => _error = 'Registration failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInput(String label, TextEditingController controller,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _colleges.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedCollege,
                    onChanged: (val) => setState(() => _selectedCollege = val),
                    items: _colleges
                        .map((college) => DropdownMenuItem(
                              value: college,
                              child: Text(college['name']),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select College',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInput('College Email', _email),
                  const SizedBox(height: 12),
                  _buildInput('Password', _password, obscure: true),
                  const SizedBox(height: 12),
                  _buildInput('Full Name', _name),
                  const SizedBox(height: 12),
                  _buildInput('Student ID', _studentId),
                  const SizedBox(height: 12),
                  _buildInput('Department / Course', _department),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _year,
                    onChanged: (val) => setState(() => _year = val!),
                    items: List.generate(
                        4,
                        (i) => DropdownMenuItem(
                            value: i + 1, child: Text('${i + 1} Year'))),
                    decoration: const InputDecoration(
                      labelText: 'Year of Study',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _registerStudent,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
      ),
    );
  }
}

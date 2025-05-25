import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  // Step 1: Hard-coded super admin login
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _authenticated = false;
  String? _loginError;

  // Step 2: College admin creation
  final _adminEmail = TextEditingController();
  final _collegeId = TextEditingController();
  final _collegeName = TextEditingController();
  bool _isCreating = false;
  String? _status;

  final String superAdminEmail = 'admin-uniclub@gmail.com';
  final String superAdminPassword = 'Admin@123';

  void _verifySuperAdmin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email == superAdminEmail && password == superAdminPassword) {
      setState(() {
        _authenticated = true;
        _loginError = null;
      });
    } else {
      setState(() {
        _loginError = 'Invalid super admin credentials';
      });
    }
  }

  Future<void> _createCollegeAdmin() async {
    final email = _adminEmail.text.trim();
    final collegeId = _collegeId.text.trim();
    final collegeName = _collegeName.text.trim();

    if (email.isEmpty || collegeId.isEmpty || collegeName.isEmpty) {
      setState(() => _status = 'Please fill all fields');
      return;
    }

    setState(() {
      _isCreating = true;
      _status = null;
    });

    try {
      // Create temp password
      final tempPassword = 'Temp@1234';
      final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: tempPassword,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
        'role': 'college_admin',
        'collegeId': collegeId,
        'collegeName': collegeName,
      });

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() {
        _status = 'College admin invited via email.';
        _adminEmail.clear();
        _collegeId.clear();
        _collegeName.clear();
      });
    } catch (e) {
      setState(() => _status = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isCreating = false);
    }
  }

  Widget _buildLoginUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Super Admin Login',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _verifySuperAdmin,
          child: const Text('Login'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF6A11CB),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_loginError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _loginError!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildAdminCreatorUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Add College Admin',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _adminEmail,
          decoration: InputDecoration(
            labelText: 'Admin Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _collegeId,
          decoration: InputDecoration(
            labelText: 'College ID',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _collegeName,
          decoration: InputDecoration(
            labelText: 'College Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _isCreating ? null : _createCollegeAdmin,
          icon: _isCreating
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: const Text('Create & Invite'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: const Color(0xFF6A11CB),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_status != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _status!,
              style: TextStyle(
                color: _status!.startsWith('Error') ? Colors.red : Colors.green,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        backgroundColor: const Color(0xFF6A11CB),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              margin: const EdgeInsets.all(24),
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _authenticated ? _buildAdminCreatorUI() : _buildLoginUI(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentEmailVerificationScreen extends StatefulWidget {
  const StudentEmailVerificationScreen({super.key});

  @override
  State<StudentEmailVerificationScreen> createState() =>
      _StudentEmailVerificationScreenState();
}

class _StudentEmailVerificationScreenState
    extends State<StudentEmailVerificationScreen> {
  bool _isVerified = false;
  bool _checking = true;

  Future<void> _checkVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    setState(() {
      _isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      _checking = false;
    });
    if (_isVerified) {
      Navigator.pushReplacementNamed(context, '/student-dashboard');
    }
  }

  Future<void> _resendEmail() async {
    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Verification email sent')));
  }

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: Center(
        child: _checking
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please verify your email to continue.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      onPressed: _checkVerification,
                      child: const Text('I Have Verified')),
                  TextButton(
                      onPressed: _resendEmail,
                      child: const Text('Resend Email')),
                ],
              ),
      ),
    );
  }
}

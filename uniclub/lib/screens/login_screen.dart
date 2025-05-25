import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/loading_spinner.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _studentEmailController = TextEditingController();
  final _studentPasswordController = TextEditingController();

  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  int _adminType = 0;
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await AuthService().login(email, password);
      final role = (await UserService().getUserRole(user!.uid))['role'];

      switch (role) {
        case 'student':
          Navigator.pushReplacementNamed(context, '/student-dashboard');
          break;
        case 'college_admin':
          Navigator.pushReplacementNamed(context, '/college-admin-dashboard');
          break;
        case 'club_admin':
          Navigator.pushReplacementNamed(context, '/club-dashboard');
          break;
        case 'super_admin':
          Navigator.pushReplacementNamed(context, '/super-admin-dashboard');
          break;
        default:
          throw Exception("Unknown role: $role");
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField(TextEditingController controller, String label, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  Widget _studentTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildInputField(_studentEmailController, 'Email'),
          const SizedBox(height: 20),
          _buildInputField(_studentPasswordController, 'Password', isPassword: true),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            onPressed: () {
              final email = _studentEmailController.text.trim();
              final pass = _studentPasswordController.text.trim();
              if (email.isEmpty || pass.isEmpty || !email.contains('@')) {
                setState(() => _error = "Enter a valid email and password");
              } else {
                _handleLogin(email, pass);
              }
            },
            label: const Text('Login'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text("Don't have an account? Register"),
          ),
        ],
      ),
    );
  }

  Widget _adminTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('College Admin')),
              ButtonSegment(value: 1, label: Text('Club Admin')),
            ],
            selected: {_adminType},
            onSelectionChanged: (s) => setState(() => _adminType = s.first),
          ),
          const SizedBox(height: 20),
          _buildInputField(_adminEmailController, 'Email'),
          const SizedBox(height: 20),
          _buildInputField(_adminPasswordController, 'Password', isPassword: true),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            onPressed: () {
              final email = _adminEmailController.text.trim();
              final pass = _adminPasswordController.text.trim();
              if (email.isEmpty || pass.isEmpty || !email.contains('@')) {
                setState(() => _error = "Enter a valid email and password");
              } else {
                _handleLogin(email, pass);
              }
            },
            label: const Text('Login'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Text(
                        'Club Management Portal',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Student'),
                          Tab(text: 'Admin'),
                        ],
                        labelColor: const Color(0xFF6A11CB),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF6A11CB),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: LoadingSpinner(),
                        )
                      else
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [_studentTab(), _adminTab()],
                          ),
                        ),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

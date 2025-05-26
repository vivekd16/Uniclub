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
  final _formKey = GlobalKey<FormState>();
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _visible = true;
      });
    });
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
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(isPassword ? Icons.lock : Icons.email),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (label == 'Email' && !value.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _studentTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min,
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
              minimumSize: const Size(double.infinity, 50),
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
    ),
  );
  }

  Widget _adminTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min,
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
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(seconds: 2),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF4DD0E1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final cardWidth = width < 600 ? width * 0.9 : 500.0;
                    return Center(
                      child: SizedBox(
                        width: cardWidth,
                        child: Card(
                    margin: const EdgeInsets.all(24),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'Club Management Portal',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TabBar(
                              controller: _tabController,
                              tabs: const [
                                Tab(text: 'Student'),
                                Tab(text: 'Admin'),
                              ],
                              labelColor: Theme.of(context).colorScheme.primary,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.transparent,
                            ),
                            const SizedBox(height: 16),
                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
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
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  _error!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.redAccent),
                                ),
                              ),
                                ],  // end Column children
                              ),  // close Column
                            ),  // close Form
                        ),  // close Padding
                      ),  // close Card
                    ),  // close SizedBox
                  );  // close Center
                },  // close builder
              ),  // close LayoutBuilder
              ),  // close Container
            ),  // close AnimatedOpacity
          ),  // close SingleChildScrollView
      ),  // close SafeArea
    ),  // close Scaffold
  );  // close DefaultTabController
  }  // end build
}  // end _LoginScreenState

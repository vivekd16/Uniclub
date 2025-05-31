import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/college_model.dart';
import '../services/college_service.dart';
import '../widgets/profile_image_picker.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final CollegeService _collegeService = CollegeService();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  CollegeModel? _college;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel != null) {
        _nameController.text = authProvider.userModel!.name;
        
        if (authProvider.userModel!.collegeId != null) {
          _college = await _collegeService.getCollegeById(authProvider.userModel!.collegeId!);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
      
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters')),
        );
        return;
      }
    }

    setState(() => _isUpdating = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel != null) {
        // Update user model
        final updatedUser = authProvider.userModel!.copyWith(
          name: _nameController.text.trim(),
          updatedAt: DateTime.now(),
        );
        
        await authProvider.updateUserModel(updatedUser);
        
        // Update password if provided
        if (_passwordController.text.isNotEmpty) {
          await authProvider.user?.updatePassword(_passwordController.text);
        }
        
        setState(() => _isEditing = false);
        _passwordController.clear();
        _confirmPasswordController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _updateProfileImage(String? imageUrl) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel != null) {
      final updatedUser = authProvider.userModel!.copyWith(
        profileImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );
      await authProvider.updateUserModel(updatedUser);
    }
  }

  Future<void> _updateBackgroundImage(String? imageUrl) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userModel != null) {
      final updatedUser = authProvider.userModel!.copyWith(
        backgroundImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );
      await authProvider.updateUserModel(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;
        
        if (_isLoading || user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              if (_isEditing)
                TextButton(
                  onPressed: _isUpdating ? null : () {
                    setState(() => _isEditing = false);
                    _nameController.text = user.name;
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                  },
                  child: const Text('Cancel'),
                )
              else
                TextButton(
                  onPressed: () => setState(() => _isEditing = true),
                  child: const Text('Edit'),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Background Image Section
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Background Image
                      Container(
                        height: 150,
                        width: double.infinity,
                        child: ProfileImagePicker(
                          currentImageUrl: user.backgroundImageUrl,
                          onImageChanged: _updateBackgroundImage,
                          userId: user.uid,
                          imageType: 'background',
                          size: double.infinity,
                          isCircular: false,
                        ),
                      ),
                      
                      // Profile Image
                      Positioned(
                        bottom: 0,
                        left: 20,
                        child: ProfileImagePicker(
                          currentImageUrl: user.profileImageUrl,
                          onImageChanged: _updateProfileImage,
                          userId: user.uid,
                          imageType: 'profile',
                          size: 100,
                          isCircular: true,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Profile Information
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email Field (Read-only)
                      TextFormField(
                        initialValue: user.email,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // College Field (Read-only)
                      TextFormField(
                        initialValue: _college?.name ?? 'No college assigned',
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'College',
                          prefixIcon: const Icon(Icons.school),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      
                      if (_isEditing) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Change Password (Optional)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // New Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Leave empty to keep current password',
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _updateProfile,
                            child: _isUpdating
                                ? const CircularProgressIndicator()
                                : const Text('Update Profile'),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Profile Stats
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Stats',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '${user.enrolledClubs.length}',
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      Text(
                                        'Clubs Joined',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        user.role.name.toUpperCase(),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                      Text(
                                        'Role',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
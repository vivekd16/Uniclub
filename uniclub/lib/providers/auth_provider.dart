import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserModel();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;
    
    try {
      _userModel = await _userService.getUserById(_user!.uid);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _user = user;
        await _loadUserModel();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }
    
    _setLoading(false);
    return false;
  }

  Future<bool> register(String email, String password, UserModel userModel) async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = await _authService.register(email, password);
      if (user != null) {
        // Create user document in Firestore
        final newUserModel = userModel.copyWith();
        await _userService.createUser(newUserModel);
        
        _user = user;
        _userModel = newUserModel;
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }
    
    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _user = null;
      _userModel = null;
    } catch (e) {
      _setError(e.toString());
    }
    
    _setLoading(false);
  }

  Future<void> updateUserModel(UserModel updatedUser) async {
    try {
      await _userService.updateUser(updatedUser);
      _userModel = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() => _clearError();
}
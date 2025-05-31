import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> login(String email, String password) async {
    try {
      final userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }

  // Register with email and password
  Future<User?> register(String email, String password) async {
    try {
      final userCredential =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration failed");
    }
  }

  // Register user with role and create Firestore document
  Future<User?> registerWithRole(
    String email,
    String password,
    UserModel userModel,
  ) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore with the Firebase Auth UID
        final newUserModel = userModel.copyWith(uid: userCredential.user!.uid);
        await _userService.createUser(newUserModel);
        
        return userCredential.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Registration failed");
    }
  }

  // Create admin user (for Super Admin use)
  Future<User?> createAdminUser(
    String email,
    String password,
    UserModel userModel,
  ) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        final newUserModel = userModel.copyWith(uid: userCredential.user!.uid);
        await _userService.createUser(newUserModel);
        
        // Send password reset email so admin can set their own password
        await _auth.sendPasswordResetEmail(email: email);
        
        return userCredential.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Admin user creation failed");
    }
  }

  // Sign out
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Password reset failed");
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Password update failed");
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      if (_auth.currentUser != null) {
        // Delete user document from Firestore
        await _userService.deleteUser(_auth.currentUser!.uid);
        
        // Delete Firebase Auth user
        await _auth.currentUser!.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Account deletion failed");
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Email verification failed");
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload user to get updated verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('User reload error: $e');
    }
  }
}

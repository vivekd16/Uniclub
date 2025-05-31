import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    
    return UserModel.fromFirestore(doc);
  }

  // Get user by UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Create new user document
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toFirestore());
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toFirestore());
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    final query = await _db
        .collection('users')
        .where('role', isEqualTo: UserModel._roleToString(role))
        .get();
    
    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Get users by college
  Future<List<UserModel>> getUsersByCollege(String collegeId) async {
    final query = await _db
        .collection('users')
        .where('collegeId', isEqualTo: collegeId)
        .get();
    
    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Get users by club
  Future<List<UserModel>> getUsersByClub(String clubId) async {
    final query = await _db
        .collection('users')
        .where('enrolledClubs', arrayContains: clubId)
        .get();
    
    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Join club
  Future<void> joinClub(String userId, String clubId) async {
    await _db.collection('users').doc(userId).update({
      'enrolledClubs': FieldValue.arrayUnion([clubId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Leave club
  Future<void> leaveClub(String userId, String clubId) async {
    await _db.collection('users').doc(userId).update({
      'enrolledClubs': FieldValue.arrayRemove([clubId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // Get all users (for super admin)
  Future<List<UserModel>> getAllUsers() async {
    final query = await _db.collection('users').get();
    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Search users
  Future<List<UserModel>> searchUsers(String searchTerm) async {
    final query = await _db
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();
    
    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Get user role (legacy method for compatibility)
  Future<Map<String, dynamic>> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception("User not found");
    }
    return doc.data()!;
  }
}

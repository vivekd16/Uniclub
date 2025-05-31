import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { superAdmin, collegeAdmin, clubAdmin, student }

class UserModel {
  final String uid;
  final String email;
  final UserRole role;
  final String name;
  final String? collegeId;
  final String? clubId;
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final List<String> enrolledClubs;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.collegeId,
    this.clubId,
    this.profileImageUrl,
    this.backgroundImageUrl,
    this.enrolledClubs = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      name: data['name'] ?? '',
      collegeId: data['collegeId'],
      clubId: data['clubId'],
      profileImageUrl: data['profileImageUrl'],
      backgroundImageUrl: data['backgroundImageUrl'],
      enrolledClubs: List<String>.from(data['enrolledClubs'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': _roleToString(role),
      'name': name,
      'collegeId': collegeId,
      'clubId': clubId,
      'profileImageUrl': profileImageUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'enrolledClubs': enrolledClubs,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? email,
    UserRole? role,
    String? name,
    String? collegeId,
    String? clubId,
    String? profileImageUrl,
    String? backgroundImageUrl,
    List<String>? enrolledClubs,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      role: role ?? this.role,
      name: name ?? this.name,
      collegeId: collegeId ?? this.collegeId,
      clubId: clubId ?? this.clubId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      enrolledClubs: enrolledClubs ?? this.enrolledClubs,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  static UserRole _parseRole(String? roleString) {
    switch (roleString) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'college_admin':
        return UserRole.collegeAdmin;
      case 'club_admin':
        return UserRole.clubAdmin;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.collegeAdmin:
        return 'college_admin';
      case UserRole.clubAdmin:
        return 'club_admin';
      case UserRole.student:
        return 'student';
    }
  }

  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isCollegeAdmin => role == UserRole.collegeAdmin;
  bool get isClubAdmin => role == UserRole.clubAdmin;
  bool get isStudent => role == UserRole.student;
}
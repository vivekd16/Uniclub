import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModel {
  final String clubId;
  final String collegeId;
  final String name;
  final String description;
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final String adminId;
  final List<String> memberUids;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClubModel({
    required this.clubId,
    required this.collegeId,
    required this.name,
    required this.description,
    this.profileImageUrl,
    this.backgroundImageUrl,
    required this.adminId,
    this.memberUids = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClubModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubModel(
      clubId: doc.id,
      collegeId: data['collegeId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      backgroundImageUrl: data['backgroundImageUrl'],
      adminId: data['adminId'] ?? '',
      memberUids: List<String>.from(data['memberUids'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'collegeId': collegeId,
      'name': name,
      'description': description,
      'profileImageUrl': profileImageUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'adminId': adminId,
      'memberUids': memberUids,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ClubModel copyWith({
    String? collegeId,
    String? name,
    String? description,
    String? profileImageUrl,
    String? backgroundImageUrl,
    String? adminId,
    List<String>? memberUids,
    DateTime? updatedAt,
  }) {
    return ClubModel(
      clubId: clubId,
      collegeId: collegeId ?? this.collegeId,
      name: name ?? this.name,
      description: description ?? this.description,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      adminId: adminId ?? this.adminId,
      memberUids: memberUids ?? this.memberUids,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  int get memberCount => memberUids.length;
  
  bool isMember(String uid) => memberUids.contains(uid);
}
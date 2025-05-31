import 'package:cloud_firestore/cloud_firestore.dart';

class CollegeModel {
  final String collegeId;
  final String name;
  final String location;
  final String description;
  final String? profileImageUrl;
  final String? backgroundImageUrl;
  final String adminId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CollegeModel({
    required this.collegeId,
    required this.name,
    required this.location,
    required this.description,
    this.profileImageUrl,
    this.backgroundImageUrl,
    required this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollegeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollegeModel(
      collegeId: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      backgroundImageUrl: data['backgroundImageUrl'],
      adminId: data['adminId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'profileImageUrl': profileImageUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'adminId': adminId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CollegeModel copyWith({
    String? name,
    String? location,
    String? description,
    String? profileImageUrl,
    String? backgroundImageUrl,
    String? adminId,
    DateTime? updatedAt,
  }) {
    return CollegeModel(
      collegeId: collegeId,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
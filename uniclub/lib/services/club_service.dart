import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/club_model.dart';

class ClubService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create club
  Future<String> createClub(ClubModel club) async {
    final docRef = await _db.collection('clubs').add(club.toFirestore());
    return docRef.id;
  }

  // Get club by ID
  Future<ClubModel?> getClubById(String clubId) async {
    final doc = await _db.collection('clubs').doc(clubId).get();
    if (!doc.exists) return null;
    return ClubModel.fromFirestore(doc);
  }

  // Get all clubs
  Future<List<ClubModel>> getAllClubs() async {
    final query = await _db.collection('clubs').orderBy('name').get();
    return query.docs.map((doc) => ClubModel.fromFirestore(doc)).toList();
  }

  // Get clubs by college
  Future<List<ClubModel>> getClubsByCollege(String collegeId) async {
    final query = await _db
        .collection('clubs')
        .where('collegeId', isEqualTo: collegeId)
        .orderBy('name')
        .get();
    
    return query.docs.map((doc) => ClubModel.fromFirestore(doc)).toList();
  }

  // Get club by admin ID
  Future<ClubModel?> getClubByAdminId(String adminId) async {
    final query = await _db
        .collection('clubs')
        .where('adminId', isEqualTo: adminId)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) return null;
    return ClubModel.fromFirestore(query.docs.first);
  }

  // Update club
  Future<void> updateClub(ClubModel club) async {
    await _db.collection('clubs').doc(club.clubId).update(club.toFirestore());
  }

  // Delete club
  Future<void> deleteClub(String clubId) async {
    await _db.collection('clubs').doc(clubId).delete();
  }

  // Add member to club
  Future<void> addMember(String clubId, String userId) async {
    await _db.collection('clubs').doc(clubId).update({
      'memberUids': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove member from club
  Future<void> removeMember(String clubId, String userId) async {
    await _db.collection('clubs').doc(clubId).update({
      'memberUids': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Search clubs
  Future<List<ClubModel>> searchClubs(String searchTerm) async {
    final query = await _db
        .collection('clubs')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();
    
    return query.docs.map((doc) => ClubModel.fromFirestore(doc)).toList();
  }

  // Get clubs that user has joined
  Future<List<ClubModel>> getUserJoinedClubs(String userId) async {
    final query = await _db
        .collection('clubs')
        .where('memberUids', arrayContains: userId)
        .get();
    
    return query.docs.map((doc) => ClubModel.fromFirestore(doc)).toList();
  }

  // Stream clubs for real-time updates
  Stream<List<ClubModel>> getClubsStream() {
    return _db
        .collection('clubs')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClubModel.fromFirestore(doc))
            .toList());
  }

  // Stream clubs by college
  Stream<List<ClubModel>> getClubsByCollegeStream(String collegeId) {
    return _db
        .collection('clubs')
        .where('collegeId', isEqualTo: collegeId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClubModel.fromFirestore(doc))
            .toList());
  }
}
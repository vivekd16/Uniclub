import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/college_model.dart';

class CollegeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create college
  Future<String> createCollege(CollegeModel college) async {
    final docRef = await _db.collection('colleges').add(college.toFirestore());
    return docRef.id;
  }

  // Get college by ID
  Future<CollegeModel?> getCollegeById(String collegeId) async {
    final doc = await _db.collection('colleges').doc(collegeId).get();
    if (!doc.exists) return null;
    return CollegeModel.fromFirestore(doc);
  }

  // Get all colleges
  Future<List<CollegeModel>> getAllColleges() async {
    final query = await _db.collection('colleges').orderBy('name').get();
    return query.docs.map((doc) => CollegeModel.fromFirestore(doc)).toList();
  }

  // Update college
  Future<void> updateCollege(CollegeModel college) async {
    await _db.collection('colleges').doc(college.collegeId).update(college.toFirestore());
  }

  // Delete college
  Future<void> deleteCollege(String collegeId) async {
    await _db.collection('colleges').doc(collegeId).delete();
  }

  // Search colleges
  Future<List<CollegeModel>> searchColleges(String searchTerm) async {
    final query = await _db
        .collection('colleges')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();
    
    return query.docs.map((doc) => CollegeModel.fromFirestore(doc)).toList();
  }

  // Get college by admin ID
  Future<CollegeModel?> getCollegeByAdminId(String adminId) async {
    final query = await _db
        .collection('colleges')
        .where('adminId', isEqualTo: adminId)
        .limit(1)
        .get();
    
    if (query.docs.isEmpty) return null;
    return CollegeModel.fromFirestore(query.docs.first);
  }

  // Stream colleges for real-time updates
  Stream<List<CollegeModel>> getCollegesStream() {
    return _db
        .collection('colleges')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollegeModel.fromFirestore(doc))
            .toList());
  }
}
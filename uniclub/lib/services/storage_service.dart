import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image
  Future<String?> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload background image
  Future<String?> uploadBackgroundImage(String userId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('background_images/$userId.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading background image: $e');
      return null;
    }
  }

  // Upload college profile image
  Future<String?> uploadCollegeProfileImage(String collegeId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('college_profiles/$collegeId.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading college profile image: $e');
      return null;
    }
  }

  // Upload college background image
  Future<String?> uploadCollegeBackgroundImage(String collegeId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('college_backgrounds/$collegeId.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading college background image: $e');
      return null;
    }
  }

  // Upload club profile image
  Future<String?> uploadClubProfileImage(String clubId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('club_profiles/$clubId.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading club profile image: $e');
      return null;
    }
  }

  // Upload club background image
  Future<String?> uploadClubBackgroundImage(String clubId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('club_backgrounds/$clubId.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading club background image: $e');
      return null;
    }
  }

  // Upload event image
  Future<String?> uploadEventImage(String eventId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('event_images/$eventId.jpg');
      final uploadTask = ref.putFile(File(imageFile.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading event image: $e');
      return null;
    }
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Pick image from gallery or camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    return await picker.pickImage(source: source);
  }
}
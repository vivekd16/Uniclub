import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/college_model.dart';
import '../models/club_model.dart';
import '../services/user_service.dart';
import '../services/college_service.dart';
import '../services/club_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final CollegeService _collegeService = CollegeService();
  final ClubService _clubService = ClubService();

  List<UserModel> _users = [];
  List<CollegeModel> _colleges = [];
  List<ClubModel> _clubs = [];
  List<ClubModel> _userJoinedClubs = [];
  
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  List<CollegeModel> get colleges => _colleges;
  List<ClubModel> get clubs => _clubs;
  List<ClubModel> get userJoinedClubs => _userJoinedClubs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all users (for super admin)
  Future<void> loadAllUsers() async {
    _setLoading(true);
    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Load users by college
  Future<void> loadUsersByCollege(String collegeId) async {
    _setLoading(true);
    try {
      _users = await _userService.getUsersByCollege(collegeId);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Load users by club
  Future<void> loadUsersByClub(String clubId) async {
    _setLoading(true);
    try {
      _users = await _userService.getUsersByClub(clubId);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Load all colleges
  Future<void> loadAllColleges() async {
    _setLoading(true);
    try {
      _colleges = await _collegeService.getAllColleges();
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Load all clubs
  Future<void> loadAllClubs() async {
    _setLoading(true);
    try {
      _clubs = await _clubService.getAllClubs();
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Load clubs by college
  Future<void> loadClubsByCollege(String collegeId) async {
    _setLoading(true);
    try {
      _clubs = await _clubService.getClubsByCollege(collegeId);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Load user's joined clubs
  Future<void> loadUserJoinedClubs(String userId) async {
    _setLoading(true);
    try {
      _userJoinedClubs = await _clubService.getUserJoinedClubs(userId);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Join club
  Future<bool> joinClub(String userId, String clubId) async {
    try {
      await _userService.joinClub(userId, clubId);
      await _clubService.addMember(clubId, userId);
      
      // Refresh user's joined clubs
      await loadUserJoinedClubs(userId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Leave club
  Future<bool> leaveClub(String userId, String clubId) async {
    try {
      await _userService.leaveClub(userId, clubId);
      await _clubService.removeMember(clubId, userId);
      
      // Refresh user's joined clubs
      await loadUserJoinedClubs(userId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Search users
  Future<void> searchUsers(String searchTerm) async {
    _setLoading(true);
    try {
      _users = await _userService.searchUsers(searchTerm);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Search colleges
  Future<void> searchColleges(String searchTerm) async {
    _setLoading(true);
    try {
      _colleges = await _collegeService.searchColleges(searchTerm);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Search clubs
  Future<void> searchClubs(String searchTerm) async {
    _setLoading(true);
    try {
      _clubs = await _clubService.searchClubs(searchTerm);
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Get college by ID
  CollegeModel? getCollegeById(String collegeId) {
    try {
      return _colleges.firstWhere((college) => college.collegeId == collegeId);
    } catch (e) {
      return null;
    }
  }

  // Get club by ID
  ClubModel? getClubById(String clubId) {
    try {
      return _clubs.firstWhere((club) => club.clubId == clubId);
    } catch (e) {
      return null;
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
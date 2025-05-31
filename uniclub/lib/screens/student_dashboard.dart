import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/club_model.dart';
import '../models/college_model.dart';
import '../models/event_model.dart';
import '../services/club_service.dart';
import '../services/college_service.dart';
import '../services/event_service.dart';
import '../widgets/club_card.dart';
import '../widgets/event_card.dart';
import '../widgets/profile_image_picker.dart';
import 'club_detail_screen.dart';
import 'student_profile_screen.dart';
import 'chat_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final ClubService _clubService = ClubService();
  final CollegeService _collegeService = CollegeService();
  final EventService _eventService = EventService();
  
  List<ClubModel> _allClubs = [];
  List<ClubModel> _filteredClubs = [];
  List<ClubModel> _joinedClubs = [];
  List<EventModel> _upcomingEvents = [];
  Map<String, CollegeModel> _colleges = {};
  
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedIndex = 0;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all clubs
      _allClubs = await _clubService.getAllClubs();
      _filteredClubs = List.from(_allClubs);
      
      // Load colleges
      final colleges = await _collegeService.getAllColleges();
      _colleges = {for (var college in colleges) college.collegeId: college};
      
      // Load user's joined clubs
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel != null) {
        _joinedClubs = await _clubService.getUserJoinedClubs(authProvider.userModel!.uid);
      }
      
      // Load upcoming events
      _upcomingEvents = await _eventService.getAllUpcomingEvents();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterClubs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredClubs = List.from(_allClubs);
      } else {
        _filteredClubs = _allClubs
            .where((club) =>
                club.name.toLowerCase().contains(query.toLowerCase()) ||
                club.description.toLowerCase().contains(query.toLowerCase()) ||
                (_colleges[club.collegeId]?.name.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  Future<void> _joinClub(ClubModel club) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.userModel == null) return;
    
    // Check if club belongs to user's college
    if (club.collegeId != authProvider.userModel!.collegeId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only join clubs from your college')),
      );
      return;
    }
    
    final success = await userProvider.joinClub(
      authProvider.userModel!.uid,
      club.clubId,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined ${club.name}')),
      );
      _loadData(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join club')),
      );
    }
  }

  Future<void> _leaveClub(ClubModel club) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.userModel == null) return;
    
    final success = await userProvider.leaveClub(
      authProvider.userModel!.uid,
      club.clubId,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Left ${club.name}')),
      );
      _loadData(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to leave club')),
      );
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clubs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _filterClubs,
            ),
          ),
          
          // Clubs List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClubs.isEmpty
                    ? const Center(child: Text('No clubs found'))
                    : ListView.builder(
                        itemCount: _filteredClubs.length,
                        itemBuilder: (context, index) {
                          final club = _filteredClubs[index];
                          final college = _colleges[club.collegeId];
                          final isJoined = _joinedClubs.any((c) => c.clubId == club.clubId);
                          final canJoin = Provider.of<AuthProvider>(context, listen: false)
                              .userModel?.collegeId == club.collegeId;
                          
                          return ClubCard(
                            club: club,
                            college: college,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClubDetailScreen(
                                  club: club,
                                  college: college,
                                ),
                              ),
                            ),
                            trailing: isJoined
                                ? ElevatedButton(
                                    onPressed: () => _leaveClub(club),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Leave'),
                                  )
                                : canJoin
                                    ? ElevatedButton(
                                        onPressed: () => _joinClub(club),
                                        child: const Text('Join'),
                                      )
                                    : const SizedBox.shrink(),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyClubsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _joinedClubs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('You haven\'t joined any clubs yet'),
                      SizedBox(height: 8),
                      Text('Browse clubs in the Home tab to join'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _joinedClubs.length,
                  itemBuilder: (context, index) {
                    final club = _joinedClubs[index];
                    final college = _colleges[club.collegeId];
                    
                    return ClubCard(
                      club: club,
                      college: college,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubDetailScreen(
                            club: club,
                            college: college,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  clubId: club.clubId,
                                  clubName: club.name,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.chat),
                            tooltip: 'Chat',
                          ),
                          ElevatedButton(
                            onPressed: () => _leaveClub(club),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Leave'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEventsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _upcomingEvents.isEmpty
              ? const Center(child: Text('No upcoming events'))
              : ListView.builder(
                  itemCount: _upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = _upcomingEvents[index];
                    return EventCard(event: event);
                  },
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClubVerse'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentProfileScreen(),
              ),
            ),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () => authProvider.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ResponsiveRowColumn(
        layout: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
            ? ResponsiveRowColumnType.COLUMN
            : ResponsiveRowColumnType.ROW,
        children: [
          ResponsiveRowColumnItem(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeTab(),
                _buildMyClubsTab(),
                _buildEventsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'My Clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

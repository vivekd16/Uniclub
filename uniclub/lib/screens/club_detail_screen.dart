import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/club_model.dart';
import '../models/college_model.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/event_service.dart';
import '../widgets/event_card.dart';
import 'chat_screen.dart';

class ClubDetailScreen extends StatefulWidget {
  final ClubModel club;
  final CollegeModel? college;

  const ClubDetailScreen({
    super.key,
    required this.club,
    this.college,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  final EventService _eventService = EventService();
  List<EventModel> _clubEvents = [];
  bool _isLoading = true;
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load club events
      _clubEvents = await _eventService.getEventsByClub(widget.club.clubId);
      
      // Check if user has joined this club
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel != null) {
        _isJoined = authProvider.userModel!.enrolledClubs.contains(widget.club.clubId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinClub() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.userModel == null) return;
    
    // Check if club belongs to user's college
    if (widget.club.collegeId != authProvider.userModel!.collegeId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only join clubs from your college')),
      );
      return;
    }
    
    final success = await userProvider.joinClub(
      authProvider.userModel!.uid,
      widget.club.clubId,
    );
    
    if (success) {
      setState(() => _isJoined = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined ${widget.club.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join club')),
      );
    }
  }

  Future<void> _leaveClub() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.userModel == null) return;
    
    final success = await userProvider.leaveClub(
      authProvider.userModel!.uid,
      widget.club.clubId,
    );
    
    if (success) {
      setState(() => _isJoined = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Left ${widget.club.name}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to leave club')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final canJoin = authProvider.userModel?.collegeId == widget.club.collegeId;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Background Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.club.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.club.backgroundImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.club.backgroundImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Club Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Club Profile and Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        backgroundImage: widget.club.profileImageUrl != null
                            ? CachedNetworkImageProvider(widget.club.profileImageUrl!)
                            : null,
                        child: widget.club.profileImageUrl == null
                            ? Icon(
                                Icons.group,
                                size: 40,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.college != null) ...[
                              Text(
                                widget.college!.name,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.club.memberCount} members',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      if (canJoin) ...[
                        Expanded(
                          child: _isJoined
                              ? ElevatedButton.icon(
                                  onPressed: _leaveClub,
                                  icon: const Icon(Icons.exit_to_app),
                                  label: const Text('Leave Club'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: _joinClub,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Join Club'),
                                ),
                        ),
                        if (_isJoined) ...[
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  clubId: widget.club.clubId,
                                  clubName: widget.club.name,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.chat),
                            label: const Text('Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ] else ...[
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'You can only join clubs from your college',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.club.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  
                  // Events Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Events',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_clubEvents.length} events',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Events List
          _isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : _clubEvents.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No events yet'),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = _clubEvents[index];
                          return EventCard(event: event);
                        },
                        childCount: _clubEvents.length,
                      ),
                    ),
        ],
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create event
  Future<String> createEvent(EventModel event) async {
    final docRef = await _db.collection('events').add(event.toFirestore());
    return docRef.id;
  }

  // Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    final doc = await _db.collection('events').doc(eventId).get();
    if (!doc.exists) return null;
    return EventModel.fromFirestore(doc);
  }

  // Get events by club
  Future<List<EventModel>> getEventsByClub(String clubId) async {
    final query = await _db
        .collection('events')
        .where('clubId', isEqualTo: clubId)
        .orderBy('date', descending: true)
        .get();
    
    return query.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }

  // Get upcoming events by club
  Future<List<EventModel>> getUpcomingEventsByClub(String clubId) async {
    final now = DateTime.now();
    final query = await _db
        .collection('events')
        .where('clubId', isEqualTo: clubId)
        .where('date', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('date')
        .get();
    
    return query.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }

  // Get all upcoming events
  Future<List<EventModel>> getAllUpcomingEvents() async {
    final now = DateTime.now();
    final query = await _db
        .collection('events')
        .where('date', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('date')
        .get();
    
    return query.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }

  // Get all events
  Future<List<EventModel>> getAllEvents() async {
    final query = await _db
        .collection('events')
        .orderBy('date', descending: true)
        .get();
    
    return query.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }

  // Update event
  Future<void> updateEvent(EventModel event) async {
    await _db.collection('events').doc(event.eventId).update(event.toFirestore());
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  // Search events
  Future<List<EventModel>> searchEvents(String searchTerm) async {
    final query = await _db
        .collection('events')
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();
    
    return query.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
  }

  // Stream events by club for real-time updates
  Stream<List<EventModel>> getEventsByClubStream(String clubId) {
    return _db
        .collection('events')
        .where('clubId', isEqualTo: clubId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  // Stream all events
  Stream<List<EventModel>> getAllEventsStream() {
    return _db
        .collection('events')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }
}
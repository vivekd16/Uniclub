import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String clubId;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.eventId,
    required this.clubId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      eventId: doc.id,
      clubId: data['clubId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clubId': clubId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': time,
      'location': location,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  EventModel copyWith({
    String? clubId,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? imageUrl,
    DateTime? updatedAt,
  }) {
    return EventModel(
      eventId: eventId,
      clubId: clubId ?? this.clubId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isPast => date.isBefore(DateTime.now());
}
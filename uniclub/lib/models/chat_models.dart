import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String chatRoomId;
  final String clubId;
  final String name;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTimestamp;

  ChatRoomModel({
    required this.chatRoomId,
    required this.clubId,
    required this.name,
    required this.participants,
    this.lastMessage,
    this.lastMessageTimestamp,
  });

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      chatRoomId: doc.id,
      clubId: data['clubId'] ?? '',
      name: data['name'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageTimestamp: data['lastMessageTimestamp'] != null
          ? (data['lastMessageTimestamp'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clubId': clubId,
      'name': name,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp != null
          ? Timestamp.fromDate(lastMessageTimestamp!)
          : null,
    };
  }

  ChatRoomModel copyWith({
    String? clubId,
    String? name,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
  }) {
    return ChatRoomModel(
      chatRoomId: chatRoomId,
      clubId: clubId ?? this.clubId,
      name: name ?? this.name,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
    );
  }
}

class MessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      messageId: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
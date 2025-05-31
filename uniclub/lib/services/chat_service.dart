import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create chat room
  Future<void> createChatRoom(ChatRoomModel chatRoom) async {
    await _db.collection('chatRooms').doc(chatRoom.chatRoomId).set(chatRoom.toFirestore());
  }

  // Get chat room by ID
  Future<ChatRoomModel?> getChatRoomById(String chatRoomId) async {
    final doc = await _db.collection('chatRooms').doc(chatRoomId).get();
    if (!doc.exists) return null;
    return ChatRoomModel.fromFirestore(doc);
  }

  // Get chat rooms for user
  Future<List<ChatRoomModel>> getChatRoomsForUser(String userId) async {
    final query = await _db
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .get();
    
    return query.docs.map((doc) => ChatRoomModel.fromFirestore(doc)).toList();
  }

  // Add participant to chat room
  Future<void> addParticipant(String chatRoomId, String userId) async {
    await _db.collection('chatRooms').doc(chatRoomId).update({
      'participants': FieldValue.arrayUnion([userId]),
    });
  }

  // Remove participant from chat room
  Future<void> removeParticipant(String chatRoomId, String userId) async {
    await _db.collection('chatRooms').doc(chatRoomId).update({
      'participants': FieldValue.arrayRemove([userId]),
    });
  }

  // Send message
  Future<void> sendMessage(String chatRoomId, MessageModel message) async {
    final batch = _db.batch();
    
    // Add message to subcollection
    final messageRef = _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc();
    
    batch.set(messageRef, message.toFirestore());
    
    // Update chat room with last message info
    final chatRoomRef = _db.collection('chatRooms').doc(chatRoomId);
    batch.update(chatRoomRef, {
      'lastMessage': message.text,
      'lastMessageTimestamp': Timestamp.fromDate(message.timestamp),
    });
    
    await batch.commit();
  }

  // Get messages for chat room
  Future<List<MessageModel>> getMessages(String chatRoomId, {int limit = 50}) async {
    final query = await _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    
    return query.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
  }

  // Stream messages for real-time chat
  Stream<List<MessageModel>> getMessagesStream(String chatRoomId, {int limit = 50}) {
    return _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  // Stream chat rooms for user
  Stream<List<ChatRoomModel>> getChatRoomsStream(String userId) {
    return _db
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromFirestore(doc))
            .toList());
  }

  // Delete chat room
  Future<void> deleteChatRoom(String chatRoomId) async {
    // Delete all messages first
    final messagesQuery = await _db
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .get();
    
    final batch = _db.batch();
    for (final doc in messagesQuery.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the chat room
    batch.delete(_db.collection('chatRooms').doc(chatRoomId));
    
    await batch.commit();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message_model.dart';

class ChatFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Ensure a chat document exists for (user, doctor) and return the chatId.
  /// chatId is a deterministic combination of the two UIDs (sorted).
  Future<String> getOrCreateChatId({required String doctorId}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final userId = user.uid;

    final parts = [userId, doctorId]..sort();
    final chatId = parts.join('_');

    final docRef = _db.collection('chats').doc(chatId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({
        'participants': [userId, doctorId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
      });
    }

    return chatId;
  }

  /// Stream messages ordered by timestamp ascending.
  Stream<List<ChatMessage>> messagesStream(String chatId) {
    final msgs = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        final senderId = data['senderId'] as String? ?? '';
        final timestampRaw = data['timestamp'];
        DateTime ts;
        if (timestampRaw is Timestamp) {
          ts = timestampRaw.toDate();
        } else if (timestampRaw is String) {
          ts = DateTime.tryParse(timestampRaw) ?? DateTime.now();
        } else {
          ts = DateTime.now();
        }

        return ChatMessage(
          id: d.id,
          content: data['content'] ?? '',
          isUser: senderId == _auth.currentUser?.uid,
          timestamp: ts,
          type: _parseMessageType(data['type'] as String?),
          metadata: data['metadata'] != null ? Map<String, dynamic>.from(data['metadata']) : null,
        );
      }).toList();
    });

    return msgs;
  }

  Future<void> sendMessage(String chatId, String content,
      {String type = 'text', Map<String, dynamic>? metadata}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final msgRef = _db.collection('chats').doc(chatId).collection('messages').doc();
    await msgRef.set({
      'senderId': user.uid,
      'content': content,
      'type': type,
      'metadata': metadata ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update chat document lastMessage/updatedAt
    await _db.collection('chats').doc(chatId).set({
      'lastMessage': content,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'symptom':
        return MessageType.symptom;
      case 'advice':
        return MessageType.advice;
      case 'emergency':
        return MessageType.emergency;
      default:
        return MessageType.text;
    }
  }
}

final chatFirestoreServiceProvider = Provider((ref) => ChatFirestoreService());

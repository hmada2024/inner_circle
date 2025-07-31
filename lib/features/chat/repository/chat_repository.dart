// lib/features/chat/repository/chat_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inner_circle/features/chat/models/message_model.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String getChatRoomId(String peerUserId) {
    final currentUserId = _auth.currentUser!.uid;
    if (currentUserId.hashCode <= peerUserId.hashCode) {
      return '${currentUserId}_$peerUserId';
    } else {
      return '${peerUserId}_$currentUserId';
    }
  }

  void sendMessage({
    required BuildContext context,
    required String text,
    required String receiverId,
  }) async {
    try {
      final timeSent = Timestamp.now();
      final senderId = _auth.currentUser!.uid;
      final messageId = const Uuid().v1();

      final message = MessageModel(
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        timestamp: timeSent,
        messageId: messageId,
      );

      final chatRoomId = getChatRoomId(receiverId);

      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الرسالة: ${e.toString()}')),
        );
      }
    }
  }

  // --- تم تعديل هذه الدالة بالكامل ---
  Stream<List<MessageModel>> getMessagesStream(String peerUserId) {
    final chatRoomId = getChatRoomId(peerUserId);

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // جلب الأحدث أولاً
        .limit(50) // تحديد العدد بـ 50 رسالة فقط
        .snapshots()
        .map((snapshot) {
      final messages =
          snapshot.docs.map((doc) => MessageModel.fromMap(doc.data())).toList();
      // عكس القائمة لعرض الأقدم في الأعلى والأحدث في الأسفل
      return messages.reversed.toList();
    });
  }

  // --- تم إضافة هذه الدالة الجديدة ---
  Stream<MessageModel?> getLastMessageStream(String peerUserId) {
    final chatRoomId = getChatRoomId(peerUserId);
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return MessageModel.fromMap(snapshot.docs.first.data());
      }
      return null;
    });
  }
}

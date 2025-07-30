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

  // دالة ذكية لإنشاء معرّف ثابت لغرفة الدردشة بين مستخدمين
  String getChatRoomId(String peerUserId) {
    final currentUserId = _auth.currentUser!.uid;
    if (currentUserId.hashCode <= peerUserId.hashCode) {
      return '${currentUserId}_$peerUserId';
    } else {
      return '${peerUserId}_$currentUserId';
    }
  }

  // الدالة الرئيسية لإرسال الرسالة
  void sendMessage({
    required BuildContext context,
    required String text,
    required String receiverId,
  }) async {
    try {
      final timeSent = Timestamp.now();
      final senderId = _auth.currentUser!.uid;
      final messageId = const Uuid().v1(); // إنشاء ID فريد للرسالة

      final message = MessageModel(
        senderId: senderId,
        receiverId: receiverId,
        text: text,
        timestamp: timeSent,
        messageId: messageId,
      );

      // 1. تحديد غرفة الدردشة الصحيحة
      final chatRoomId = getChatRoomId(receiverId);

      // 2. إرسال الرسالة إلى المجموعة الفرعية 'messages' داخل غرفة الدردشة
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
}

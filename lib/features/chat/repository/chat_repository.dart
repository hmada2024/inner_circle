// lib/features/chat/repository/chat_repository.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:inner_circle/core/models/user_model.dart';
import 'package:inner_circle/features/chat/models/message_model.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage; // --- جديد: للوصول إلى Storage

  ChatRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage, // --- جديد: حقن Storage
  })  : _firestore = firestore,
        _auth = auth,
        _storage = storage;

  String getChatRoomId(String peerUserId) {
    final currentUserId = _auth.currentUser!.uid;
    if (currentUserId.hashCode <= peerUserId.hashCode) {
      return '${currentUserId}_$peerUserId';
    } else {
      return '${peerUserId}_$currentUserId';
    }
  }

  // --- جديد: دالة لإرسال الرسائل مع كل الميزات الجديدة ---
  void sendMessage({
    required BuildContext context,
    required String text,
    required String receiverId,
    required UserModel senderUser,
    File? imageFile,
    MessageModel? repliedToMessage,
  }) async {
    try {
      final timeSent = Timestamp.now();
      final messageId = const Uuid().v1();
      final chatRoomId = getChatRoomId(receiverId);
      String? imageUrl;
      MessageType messageType = MessageType.text;

      // 1. إذا كانت هناك صورة، ارفعها أولاً
      if (imageFile != null) {
        messageType = MessageType.image;
        final ref = _storage
            .ref()
            .child('chat_images')
            .child(chatRoomId)
            .child(messageId);
        final uploadTask = await ref.putFile(imageFile);
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      // 2. إنشاء نموذج الرسالة
      final message = MessageModel(
        senderId: senderUser.uid,
        receiverId: receiverId,
        text: text, // النص يكون تعليقاً على الصورة إذا وُجدت
        timestamp: timeSent,
        messageId: messageId,
        messageType: messageType,
        imageUrl: imageUrl,
        repliedToMessageText: repliedToMessage?.text,
        repliedToSenderName: repliedToMessage == null
            ? null
            : (repliedToMessage.senderId == senderUser.uid
                ? 'نفسك'
                : (await _firestore
                        .collection('users')
                        .doc(repliedToMessage.senderId)
                        .get())
                    .data()?['name']),
      );

      // 3. حفظ الرسالة في Firestore
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

  Stream<List<MessageModel>> getMessagesStream(String peerUserId) {
    final chatRoomId = getChatRoomId(peerUserId);

    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data()))
          .toList();
    });
  }

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

  Future<void> reactToMessage(
      String peerUserId, String messageId, String reaction) async {
    final chatRoomId = getChatRoomId(peerUserId);
    final currentUserId = _auth.currentUser!.uid;

    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'reactions.$currentUserId': reaction,
    });
  }

  Future<void> markMessagesAsRead(String peerUserId) async {
    final chatRoomId = getChatRoomId(peerUserId);
    final currentUserId = _auth.currentUser!.uid;

    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}

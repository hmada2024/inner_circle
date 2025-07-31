// lib/features/chat/models/message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// --- جديد: تحديد أنواع الرسائل الممكنة ---
enum MessageType {
  text,
  image,
}

class MessageModel {
  final String senderId;
  final String receiverId;
  final String text;
  final Timestamp timestamp;
  final String messageId;
  final bool isRead; // --- جديد: لتتبع حالة القراءة
  final MessageType messageType; // --- جديد: لتحديد نوع الرسالة
  final String? imageUrl; // --- جديد: رابط الصورة المرسلة
  final Map<String, String> reactions; // --- جديد: لتخزين التفاعلات
  final String? repliedToMessageText; // --- جديد: نص الرسالة المردود عليها
  final String? repliedToSenderName; // --- جديد: اسم صاحب الرسالة المردود عليها

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.messageId,
    this.isRead = false,
    required this.messageType,
    this.imageUrl,
    this.reactions = const {},
    this.repliedToMessageText,
    this.repliedToSenderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
      'messageId': messageId,
      'isRead': isRead,
      'messageType': messageType.name, // حفظ اسم النوع كنص
      'imageUrl': imageUrl,
      'reactions': reactions,
      'repliedToMessageText': repliedToMessageText,
      'repliedToSenderName': repliedToSenderName,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      messageId: map['messageId'] ?? '',
      isRead: map['isRead'] ?? false,
      // تحويل النص المحفوظ إلى النوع الصحيح
      messageType: (map['messageType'] as String?) == 'image'
          ? MessageType.image
          : MessageType.text,
      imageUrl: map['imageUrl'],
      reactions: Map<String, String>.from(map['reactions'] ?? {}),
      repliedToMessageText: map['repliedToMessageText'],
      repliedToSenderName: map['repliedToSenderName'],
    );
  }
}

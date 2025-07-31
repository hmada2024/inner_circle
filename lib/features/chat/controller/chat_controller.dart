// lib/features/chat/controller/chat_controller.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_circle/core/providers/firebase_providers.dart';
import 'package:inner_circle/features/auth/controller/user_controller.dart';
import 'package:inner_circle/features/chat/models/message_model.dart';
import 'package:inner_circle/features/chat/repository/chat_repository.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: ref.read(firebaseFirestoreProvider),
    auth: ref.read(firebaseAuthProvider),
    storage: ref.read(firebaseStorageProvider),
  ),
);

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository, ref: ref);
});

final messagesStreamProvider = StreamProvider.autoDispose
    .family<List<MessageModel>, String>((ref, peerUserId) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getMessagesStream(peerUserId);
});

final lastMessageProvider =
    StreamProvider.autoDispose.family<MessageModel?, String>((ref, peerUserId) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getLastMessageStream(peerUserId);
});

class ChatController {
  final ChatRepository _chatRepository;
  final Ref _ref;

  ChatController({required ChatRepository chatRepository, required Ref ref})
      : _chatRepository = chatRepository,
        _ref = ref;

  void sendMessage({
    required BuildContext context,
    required String text,
    required String receiverId,
    File? imageFile,
    MessageModel? repliedToMessage,
  }) {
    _ref.read(userDataProvider).whenData((senderUser) {
      if (senderUser != null) {
        _chatRepository.sendMessage(
          context: context,
          text: text,
          receiverId: receiverId,
          senderUser: senderUser,
          imageFile: imageFile,
          repliedToMessage: repliedToMessage,
        );
      }
    });
  }

  Stream<List<MessageModel>> getMessagesStream(String peerUserId) {
    return _chatRepository.getMessagesStream(peerUserId);
  }

  Stream<MessageModel?> getLastMessageStream(String peerUserId) {
    return _chatRepository.getLastMessageStream(peerUserId);
  }

  void pickAndSendImage({
    required BuildContext context,
    required String receiverId,
    required MessageModel? repliedToMessage,
  }) async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 70);

      // إذا قام المستخدم بإلغاء اختيار الصورة، نتوقف هنا
      if (pickedFile == null) return;

      // --- سطر الإصلاح الرئيسي ---
      // قبل استخدام الـ context لإرسال الرسالة، نتأكد أن المستخدم لم يغادر الشاشة
      // أثناء نافذة اختيار الصورة. هذا يمنع انهيار التطبيق.
      if (!context.mounted) return;

      sendMessage(
        context: context,
        text:
            '', // النص المصاحب للصورة (caption). يُترك فارغاً حالياً لعدم وجود حقل إدخال له.
        receiverId: receiverId,
        imageFile: File(pickedFile.path),
        repliedToMessage: repliedToMessage,
      );
    } catch (e) {
      // نفس التحقق ضروري هنا أيضاً قبل إظهار أي رسالة خطأ
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطأ في اختيار الصورة: $e')));
      }
    }
  }

  void reactToMessage(String peerUserId, String messageId, String reaction) {
    _chatRepository.reactToMessage(peerUserId, messageId, reaction);
  }

  void markChatAsRead(String peerUserId) {
    _chatRepository.markMessagesAsRead(peerUserId);
  }
}

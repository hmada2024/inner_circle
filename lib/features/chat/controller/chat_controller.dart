// lib/features/chat/controller/chat_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/providers/firebase_providers.dart';
import 'package:inner_circle/features/chat/models/message_model.dart';
import 'package:inner_circle/features/chat/repository/chat_repository.dart';

// Provider لتوفير نسخة من ChatRepository
final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    firestore: ref.read(firebaseFirestoreProvider),
    auth: ref.read(firebaseAuthProvider),
  ),
);

// Provider للوصول إلى ChatController
final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(chatRepository: chatRepository);
});

// Provider لجلب قائمة الرسائل للمحادثة
final messagesStreamProvider = StreamProvider.autoDispose
    .family<List<MessageModel>, String>((ref, peerUserId) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getMessagesStream(peerUserId);
});

// --- تم إضافة هذا الـ Provider الجديد ---
final lastMessageProvider =
    StreamProvider.autoDispose.family<MessageModel?, String>((ref, peerUserId) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getLastMessageStream(peerUserId);
});

class ChatController {
  final ChatRepository _chatRepository;

  ChatController({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  void sendMessage({
    required BuildContext context,
    required String text,
    required String receiverId,
  }) {
    _chatRepository.sendMessage(
      context: context,
      text: text,
      receiverId: receiverId,
    );
  }

  Stream<List<MessageModel>> getMessagesStream(String peerUserId) {
    return _chatRepository.getMessagesStream(peerUserId);
  }

  // --- تم إضافة هذه الدالة الجديدة ---
  Stream<MessageModel?> getLastMessageStream(String peerUserId) {
    return _chatRepository.getLastMessageStream(peerUserId);
  }
}

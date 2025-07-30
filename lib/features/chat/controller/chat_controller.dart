// lib/features/chat/controller/chat_controller.dart (النسخة الكاملة والصحيحة)

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

// تم تعريفه الآن بشكل كامل وصحيح
final messagesStreamProvider = StreamProvider.autoDispose
    .family<List<MessageModel>, String>((ref, peerUserId) {
  final chatController = ref.watch(chatControllerProvider);
  return chatController.getMessagesStream(peerUserId);
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

  // دالة جلب الرسائل (كاملة)
  Stream<List<MessageModel>> getMessagesStream(String peerUserId) {
    return _chatRepository.getMessagesStream(peerUserId);
  }
}

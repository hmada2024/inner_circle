// lib/features/chat/screens/chat_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/models/user_model.dart';
import 'package:inner_circle/features/chat/controller/chat_controller.dart';
import 'package:inner_circle/features/chat/models/message_model.dart';
import 'package:inner_circle/features/chat/widgets/message_bubble.dart';

// --- جديد: Provider لإدارة حالة الرد على رسالة ---
final replyingToProvider = StateProvider<MessageModel?>((ref) => null);

class ChatScreen extends ConsumerStatefulWidget {
  final UserModel peerUser;

  const ChatScreen({
    super.key,
    required this.peerUser,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // --- جديد: وضع علامة "مقروءة" على الرسائل عند فتح الشاشة ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider).markChatAsRead(widget.peerUser.uid);
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final messageText = messageController.text.trim();
    final repliedToMessage = ref.read(replyingToProvider);

    if (messageText.isNotEmpty) {
      ref.read(chatControllerProvider).sendMessage(
            context: context,
            text: messageText,
            receiverId: widget.peerUser.uid,
            repliedToMessage: repliedToMessage,
          );
      messageController.clear();
      ref.read(replyingToProvider.notifier).state = null; // إلغاء الرد
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final repliedToMessage = ref.watch(replyingToProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUser.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ref.watch(messagesStreamProvider(widget.peerUser.uid)).when(
                  data: (messages) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUserId;
                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          peerUser: widget.peerUser,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
                ),
          ),
          // --- جديد: عرض معاينة الرد ---
          if (repliedToMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرد على ${repliedToMessage.senderId == currentUserId ? "نفسك" : widget.peerUser.name}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        Text(
                          repliedToMessage.messageType == MessageType.text
                              ? repliedToMessage.text
                              : '📷 صورة',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(replyingToProvider.notifier).state = null;
                    },
                  )
                ],
              ),
            ),
          // --------------------------
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    // --- جديد: السماح بتعدد الأسطر ---
                    maxLines: 5,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك هنا...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // --- جديد: زر إرفاق صورة ---
                IconButton(
                  icon: const Icon(Icons.photo_camera_back_outlined),
                  onPressed: () {
                    ref.read(chatControllerProvider).pickAndSendImage(
                          context: context,
                          receiverId: widget.peerUser.uid,
                          repliedToMessage: repliedToMessage,
                        );
                  },
                ),
                // --------------------------
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// lib/features/chat/screens/chat_screen.dart (النسخة النهائية الكاملة)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/models/user_model.dart';
import 'package:inner_circle/features/chat/controller/chat_controller.dart';
import 'package:inner_circle/features/chat/widgets/message_bubble.dart';

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
  final ScrollController _scrollController =
      ScrollController(); // للتحكم في التمرير

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isNotEmpty) {
      ref.read(chatControllerProvider).sendMessage(
            context: context,
            text: messageText,
            receiverId: widget.peerUser.uid,
          );
      messageController.clear();
      // تحريك القائمة للأسفل عند إرسال رسالة جديدة
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUser.name),
      ),
      body: Column(
        children: [
          // --- هذا الجزء هو الجزء الذي تم تغييره بالكامل ---
          Expanded(
            // نراقب الـ provider الذي يجلب الرسائل
            child: ref.watch(messagesStreamProvider(widget.peerUser.uid)).when(
                  // في حالة النجاح وجلب البيانات
                  data: (messages) {
                    // تحريك القائمة للأسفل تلقائياً عند فتح الشاشة أو وصول رسالة جديدة
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
                        return MessageBubble(message: message, isMe: isMe);
                      },
                    );
                  },
                  // أثناء التحميل
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  // في حالة الخطأ
                  error: (err, stack) => Center(child: Text('حدث خطأ: $err')),
                ),
          ),
          // --- جزء الإرسال يبقى كما هو ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك هنا...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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

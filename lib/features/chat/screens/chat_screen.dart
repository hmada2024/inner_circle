// lib/features/chat/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/models/user_model.dart';
import 'package:inner_circle/features/chat/controller/chat_controller.dart';

// تحويلها إلى ConsumerStatefulWidget لتكون قادرة على إدارة الحالة والتفاعل مع Providers
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
  // Controller للتحكم في حقل النص
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // --- دالة إرسال الرسالة النهائية ---
  void sendMessage() {
    final messageText = messageController.text.trim();
    // التأكد من أن الرسالة ليست فارغة قبل إرسالها
    if (messageText.isNotEmpty) {
      // استدعاء وحدة التحكم لإرسال الرسالة
      ref.read(chatControllerProvider).sendMessage(
            context: context,
            text: messageText,
            receiverId: widget.peerUser.uid, // UID الخاص بالمستخدم الآخر
          );
      // مسح حقل النص بعد الإرسال مباشرةً
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUser.name),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text('هنا ستظهر الرسائل قريباً!'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController, // ربط الـ controller
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك هنا...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // --- الزر الآن يعمل بشكل كامل ---
                IconButton(
                  icon: const Icon(Icons.send),
                  // عند الضغط، يتم استدعاء دالتنا الاحترافية
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
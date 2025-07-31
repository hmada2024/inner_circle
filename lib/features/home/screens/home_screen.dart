// lib/features/home/screens/home_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/models/user_model.dart';
import 'package:inner_circle/features/chat/controller/chat_controller.dart';
import 'package:inner_circle/features/chat/screens/chat_screen.dart';
import 'package:inner_circle/features/home/controller/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void navigateToChatScreen(BuildContext context, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(peerUser: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inner Circle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: ref.watch(usersProvider).when(
            data: (users) {
              if (users.isEmpty) {
                return const Center(
                  child: Text('سيظهر أصدقاؤك هنا عند انضمامهم'),
                );
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  // تغليف ListTile بـ Consumer للوصول لـ ref
                  return Consumer(
                    builder: (context, ref, child) {
                      // مراقبة الـ provider الخاص بآخر رسالة لهذا المستخدم
                      final lastMessageAsyncValue =
                          ref.watch(lastMessageProvider(user.uid));

                      return lastMessageAsyncValue.when(
                        data: (lastMessage) {
                          // --- جديد: التحقق من وجود رسائل غير مقروءة ---
                          final isUnread = lastMessage != null &&
                              !lastMessage.isRead &&
                              lastMessage.senderId != currentUserId;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            leading: CircleAvatar(
                              radius: 28,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(user.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              lastMessage != null
                                  ? (lastMessage.senderId == currentUserId
                                      ? 'أنت: ${lastMessage.text}'
                                      : lastMessage.text)
                                  : 'ابدأ المحادثة...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              // --- جديد: تغيير شكل النص غير المقروء ---
                              style: TextStyle(
                                  color: isUnread
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade600,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14),
                            ),
                            // --- جديد: إظهار مؤشر للرسائل غير المقروءة ---
                            trailing: isUnread
                                ? CircleAvatar(
                                    radius: 8,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              navigateToChatScreen(context, user);
                            },
                          );
                        },
                        loading: () => ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          leading: CircleAvatar(
                            radius: 28,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: const Text('جارِ التحميل...'),
                        ),
                        error: (err, stack) => ListTile(
                          title: Text(user.name),
                          subtitle: const Text('خطأ في تحميل الرسالة'),
                        ),
                      );
                    },
                  );
                },
              );
            },
            error: (err, stack) => Center(
              child: Text('حدث خطأ: ${err.toString()}'),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }
}

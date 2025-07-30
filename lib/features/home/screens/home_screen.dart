// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/features/home/controller/home_controller.dart';
// الخطوة 2.1: استيراد شاشة المحادثة الجديدة ونموذج المستخدم
import 'package:inner_circle/features/chat/screens/chat_screen.dart';
import 'package:inner_circle/core/models/user_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // الخطوة 2.2: إنشاء دالة للانتقال لجعل الكود أنظف
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدائرة المقربة'),
      ),
      body: ref.watch(usersProvider).when(
            data: (users) {
              if (users.isEmpty) {
                return const Center(
                  child: Text('لا يوجد مستخدمون آخرون في الدائرة بعد.'),
                );
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?'),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    // الخطوة 2.3: استبدال الـ print بالانتقال الفعلي
                    onTap: () {
                      // هذا هو الأسلوب الاحترافي للانتقال بين الشاشات
                      // مع تمرير البيانات المطلوبة (بيانات المستخدم الآخر)
                      navigateToChatScreen(context, user);
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

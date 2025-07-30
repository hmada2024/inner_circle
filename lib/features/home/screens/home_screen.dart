// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/features/home/controller/home_controller.dart';

// تحويلها إلى ConsumerWidget لتتمكن من "مشاهدة" الـ Providers
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدائرة المقربة'),
      ),
      // نستخدم ref.watch لمراقبة usersProvider والحصول على قائمة المستخدمين
      body: ref.watch(usersProvider).when(
            // في حالة النجاح وجلب البيانات
            data: (users) {
              // إذا كانت القائمة فارغة (لا يوجد مستخدمون آخرون بعد)
              if (users.isEmpty) {
                return const Center(
                  child: Text('لا يوجد مستخدمون آخرون في الدائرة بعد.'),
                );
              }
              // إذا كانت هناك بيانات، نعرضها في قائمة
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    // صورة المستخدم (أو الحرف الأول من اسمه كبداية)
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?'),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    onTap: () {
                      // TODO: عند الضغط، يتم الانتقال إلى شاشة المحادثة مع هذا المستخدم
                      print('Starting chat with ${user.name}');
                    },
                  );
                },
              );
            },
            // في حالة وجود خطأ
            error: (err, stack) => Center(
              child: Text('حدث خطأ: ${err.toString()}'),
            ),
            // أثناء تحميل البيانات
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }
}

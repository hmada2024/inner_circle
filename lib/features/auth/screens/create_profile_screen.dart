// lib/features/auth/screens/create_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/features/auth/controller/user_controller.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final nameController = TextEditingController();
  bool _isLoading = false; // متغير لتتبع حالة التحميل

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void saveProfile() async {
    String name = nameController.text.trim();

    if (name.isNotEmpty) {
      // 1. تفعيل حالة التحميل وتحديث الواجهة
      setState(() {
        _isLoading = true;
      });

      // 2. انتظار اكتمال عملية الحفظ في قاعدة البيانات
      await ref.read(userControllerProvider).saveUserDataToFirestore(
            context: context,
            name: name,
          );

      // 3. (الخطوة السحرية) إبطال الـ provider لإجباره على التحديث
      // هذا سيجعل main.dart يعيد التحقق وينقلنا للشاشة الرئيسية
      ref.invalidate(userDataProvider);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسمك')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد الملف الشخصي')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('خطوة أخيرة!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text('الرجاء إدخال اسمك ليتمكن أصدقاؤك من التعرف عليك',
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)),
                  child: const Text('حفظ والمتابعة'),
                )
            ],
          ),
        ),
      ),
    );
  }
}

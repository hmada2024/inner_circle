import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/providers/firebase_providers.dart';
import 'package:inner_circle/features/auth/screens/login_screen.dart';
import 'package:inner_circle/features/home/screens/home_screen.dart';
import 'package:inner_circle/firebase_options.dart';

void main() async {
  // تأكد من تهيئة Flutter قبل تشغيل أي شيء آخر
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // تشغيل التطبيق مع ProviderScope الخاص بـ Riverpod
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'الدائرة المقربة',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      // نستخدم authStateChangesProvider لتحديد ما إذا كان المستخدم مسجلاً أم لا
      home: ref.watch(authStateChangesProvider).when(
            data: (user) {
              if (user != null) {
                // إذا كان المستخدم مسجلاً، اذهب للشاشة الرئيسية
                return const HomeScreen();
              }
              // إذا لم يكن مسجلاً، اذهب لشاشة تسجيل الدخول
              return const LoginScreen();
            },
            // حالة التحميل أثناء التحقق من حالة المصادقة
            loading: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            // حالة الخطأ
            error: (err, stack) => Scaffold(
              body: Center(
                child: Text('حدث خطأ: $err'),
              ),
            ),
          ),
    );
  }
}

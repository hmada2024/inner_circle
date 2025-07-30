// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/providers/firebase_providers.dart';
import 'package:inner_circle/features/auth/controller/user_controller.dart';
import 'package:inner_circle/features/auth/screens/create_profile_screen.dart';
import 'package:inner_circle/features/auth/screens/login_screen.dart';
import 'package:inner_circle/features/home/screens/home_screen.dart';
import 'package:inner_circle/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    // --- الشريان الرئيسي للتطبيق ---
    // هذا هو المنطق الذي يقرر أي شاشة يجب عرضها
    return MaterialApp(
      title: 'الدائرة المقربة',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: ref.watch(authStateChangesProvider).when(
            data: (user) {
              // السؤال الأول: هل المستخدم مسجل دخوله؟
              if (user == null) {
                // الجواب: لا. إذن اذهب إلى شاشة تسجيل الدخول.
                return const LoginScreen();
              }
              // الجواب: نعم. الآن اسأل السؤال الثاني...
              // السؤال الثاني: هل لهذا المستخدم ملف شخصي؟
              return ref.watch(userDataProvider).when(
                    data: (userModel) {
                      if (userModel != null) {
                        // الجواب: نعم، لديه ملف شخصي. إذن اذهب للشاشة الرئيسية.
                        return const HomeScreen();
                      }
                      // الجواب: لا، ليس لديه ملف شخصي. إذن اذهب لشاشة إنشاء الملف الشخصي.
                      return const CreateProfileScreen();
                    },
                    // حالة تحميل أثناء جلب الملف الشخصي
                    loading: () => const Scaffold(
                        body: Center(child: CircularProgressIndicator())),
                    error: (err, stack) =>
                        Scaffold(body: Center(child: Text('حدث خطأ: $err'))),
                  );
            },
            // حالة تحميل أثناء التحقق من حالة المصادقة
            loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator())),
            error: (err, stack) =>
                Scaffold(body: Center(child: Text('حدث خطأ: $err'))),
          ),
    );
  }
}

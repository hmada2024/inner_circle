// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <<<--- تم إضافة هذا السطر
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
  // --- جديد: إعداد الإشعارات الفورية ---
  final fcm = FirebaseMessaging.instance;
  // طلب صلاحية استقبال الإشعارات من المستخدم
  await fcm.requestPermission();
  // يمكنك استخدام هذا التوكن لإرسال إشعارات لجهاز معين من السيرفر
  final token = await fcm.getToken();
  debugPrint('Firebase Messaging Token: $token');
  // ------------------------------------

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
    return MaterialApp(
      title: 'Inner Circle',
      // --- جديد: إضافة الوضع الفاتح والداكن ---
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system, // يتبع إعدادات النظام تلقائياً
      // ------------------------------------
      debugShowCheckedModeBanner: false,
      home: ref.watch(authStateChangesProvider).when(
            data: (user) {
              if (user == null) {
                return const LoginScreen();
              }
              return ref.watch(userDataProvider).when(
                    data: (userModel) {
                      if (userModel != null) {
                        return const HomeScreen();
                      }
                      return const CreateProfileScreen();
                    },
                    loading: () => const Scaffold(
                        body: Center(child: CircularProgressIndicator())),
                    error: (err, stack) =>
                        Scaffold(body: Center(child: Text('حدث خطأ: $err'))),
                  );
            },
            loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator())),
            error: (err, stack) =>
                Scaffold(body: Center(child: Text('حدث خطأ: $err'))),
          ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // تم تحسين الدوال لإظهار رسالة للمستخدم
    void signUp() {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isNotEmpty && password.isNotEmpty) {
        ref.read(authControllerProvider.notifier).signUpWithEmail(
              email: email,
              password: password,
              context: context,
            );
      } else {
        // إذا كانت الحقول فارغة، أظهر هذه الرسالة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('الرجاء ملء البريد الإلكتروني وكلمة المرور')),
        );
      }
    }

    void signIn() {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isNotEmpty && password.isNotEmpty) {
        ref.read(authControllerProvider.notifier).signInWithEmail(
              email: email,
              password: password,
              context: context,
            );
      } else {
        // إذا كانت الحقول فارغة، أظهر هذه الرسالة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('الرجاء ملء البريد الإلكتروني وكلمة المرور')),
        );
      }
    }

    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الدائرة المقربة'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 120,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Text('مرحباً بك',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                          labelText: 'كلمة المرور',
                          border: OutlineInputBorder()),
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: signIn,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50)),
                            child: const Text('تسجيل الدخول'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: signUp,
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50)),
                            child: const Text('إنشاء حساب جديد'),
                          ),
                        ],
                      ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

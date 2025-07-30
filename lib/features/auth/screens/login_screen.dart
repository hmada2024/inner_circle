import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/features/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  String normalizePhoneNumber(String phone) {
    String normalized = phone.trim();

    // 2. إذا كان الرقم يبدأ بـ "00"، استبدلها بـ "+"
    if (normalized.startsWith('00')) {
      normalized = '+${normalized.substring(2)}';
    }
    // 3. إذا كان الرقم يبدأ بـ "01" (رقم مصري محلي)، أضف كود الدولة
    // (هذا افتراض بناءً على الأرقام المستخدمة، ويمكن تعديله)
    else if (normalized.startsWith('01')) {
      normalized = '+20${normalized.substring(1)}';
    }

    // إذا كان الرقم يبدأ بـ "+" بالفعل، فهو بالفعل بالصيغة الصحيحة
    return normalized;
  }
  // --- نهاية الدالة الجديدة ---

  void sendPhoneNumber() {
    String rawPhoneNumber = phoneController.text;

    if (rawPhoneNumber.isNotEmpty) {
      // --- التعديل هنا ---
      // نقوم بتوحيد صيغة الرقم قبل إرساله
      String finalPhoneNumber = normalizePhoneNumber(rawPhoneNumber);
      // --- نهاية التعديل ---

      // الآن نرسل الرقم بالصيغة الموحدة دائماً
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, finalPhoneNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'مرحباً بك في الدائرة المقربة',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'الرجاء إدخال رقم هاتفك للتحقق من أنك ضمن القائمة المصرح بها',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: phoneController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '01001234567', // تغيير النص الإرشادي للصيغة المحلية
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const Spacer(),
              SizedBox(
                width: size.width * 0.9,
                child: ElevatedButton(
                  onPressed: sendPhoneNumber,
                  child: const Text('إرسال رمز التحقق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

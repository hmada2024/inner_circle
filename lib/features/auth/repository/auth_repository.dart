import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  // دالة للتحقق مما إذا كان الرقم في القائمة البيضاء (النسخة المحصنة)
  Future<bool> isPhoneWhitelisted(String phoneNumber) async {
    try {
      final whitelistDoc =
          await _firestore.collection('settings').doc('whitelist').get();
      if (whitelistDoc.exists) {
        final List<dynamic> allowedPhones =
            whitelistDoc.data()?['allowedPhones'] ?? [];

        // التحصين ضد الأخطاء:
        // نقوم بالمرور على كل عنصر في القائمة، وتحويله لنص، وتنظيفه من أي
        // مسافات بيضاء قد تكون أُضيفت بالخطأ في قاعدة البيانات، ثم نقارنه.
        for (var allowedPhone in allowedPhones) {
          if (allowedPhone.toString().trim() == phoneNumber) {
            return true; // وجدنا تطابقاً!
          }
        }
        // إذا انتهت الحلقة ولم نجد تطابقاً، نرجع false
        return false;
      }
      // إذا لم يوجد المستند نفسه، فبالتأكيد الرقم غير موجود
      return false;
    } catch (e) {
      // طباعة الخطأ في الكونسول للمساعدة في تصحيح الأخطاء مستقبلاً
      debugPrint("Error in isPhoneWhitelisted: ${e.toString()}");
      return false;
    }
  }

  // دالة لبدء عملية المصادقة وإرسال OTP
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      // 1. التحقق من القائمة البيضاء أولاً
      final isAllowed = await isPhoneWhitelisted(phoneNumber);
      if (!isAllowed) {
        // استخدام if (context.mounted) هو ممارسة جيدة لتجنب الأخطاء
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('هذا الرقم غير مصرح له بالانضمام')),
          );
        }
        return; // إيقاف العملية
      }

      // 2. إذا كان مسموحاً به، نبدأ عملية المصادقة مع Firebase
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // هذه الحالة تحدث عندما يتحقق Firebase من الرقم تلقائياً (نادرة على الأجهزة الحقيقية)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          // في حالة فشل التحقق (رقم غير صحيح، مشاكل شبكة، إلخ)
          throw Exception(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          // أهم جزء: عند إرسال الكود بنجاح
          // TODO: الانتقال إلى شاشة OTP مع verificationId
          // سنقوم ببناء هذه الشاشة في الخطوة التالية
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم إرسال رمز التحقق إلى $phoneNumber')),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // تحدث عند انتهاء مهلة التحقق التلقائي
        },
      );
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'حدث خطأ غير متوقع')),
        );
      }
    }
  }
}

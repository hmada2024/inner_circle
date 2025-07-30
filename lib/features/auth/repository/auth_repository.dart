// features/auth/repository/auth_repository.dart

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

  Future<bool> isPhoneWhitelisted(String phoneNumber) async {
    try {
      final whitelistDoc =
          await _firestore.collection('settings').doc('whitelist').get();
      if (whitelistDoc.exists) {
        final List<dynamic> allowedPhones =
            whitelistDoc.data()?['allowedPhones'] ?? [];
        for (var allowedPhone in allowedPhones) {
          if (allowedPhone.toString().trim() == phoneNumber) {
            return true;
          }
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint("Error in isPhoneWhitelisted: ${e.toString()}");
      return false;
    }
  }

  // دالة لبدء عملية المصادقة وإرسال OTP
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      final isAllowed = await isPhoneWhitelisted(phoneNumber);

      // ================== قسم التشخيص المرئي ==================
      // إذا لم يكن الرقم مسموحاً به، سنقوم بعرض رسالة تشخيصية مفصلة
      // بدلاً من الرسالة العامة، وذلك لمرة واحدة فقط.
      if (!isAllowed) {
        // 1. نحضر القائمة البيضاء مرة أخرى لنعرضها
        final whitelistDoc =
            await _firestore.collection('settings').doc('whitelist').get();
        final List<dynamic> dbPhones =
            whitelistDoc.data()?['allowedPhones'] ?? ['القائمة فارغة'];

        // 2. نعرض الرسالة التشخيصية المفصلة
        if (context.mounted) {
          // رسالة توضح ما تم مقارنته بالضبط
          final debugMessage =
              "فشل التحقق | الإدخال: [$phoneNumber] | القائمة في DB: $dbPhones";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(debugMessage),
              duration: const Duration(seconds: 10), // مدة أطول لرؤيتها بوضوح
              backgroundColor: Colors.red, // لون مميز للخطأ
            ),
          );
        }
        return; // إيقاف العملية
      }
      // ================== نهاية قسم التشخيص ==================

      // إذا نجح التحقق، نستكمل الكود كالمعتاد
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرقم مصرح به، جاري إرسال الرمز...')),
        );
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم إرسال رمز التحقق إلى $phoneNumber')),
            );
          }
          // TODO: الانتقال إلى شاشة OTP
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
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

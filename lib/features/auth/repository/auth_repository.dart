// features/auth/repository/auth_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inner_circle/core/utils.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isEmailWhitelisted(String email) async {
    try {
      final whitelistDoc =
          await _firestore.collection('settings').doc('whitelist').get();
      if (whitelistDoc.exists) {
        final List<dynamic> allowedEmails =
            whitelistDoc.data()?['allowedEmails'] ?? [];
        return allowedEmails
            .map((e) => e.toString().toLowerCase().trim())
            .contains(email.toLowerCase().trim());
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // 1. التحقق من القائمة البيضاء أولاً
      final isAllowed = await isEmailWhitelisted(email);
      if (!context.mounted) return;

      if (!isAllowed) {
        showCustomSnackBar(
          context: context,
          content: 'عذراً، هذا البريد الإلكتروني غير مصرح له بالانضمام.',
          isError: true,
        );
        return;
      }

      // 2. محاولة إنشاء الحساب
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'هذا البريد الإلكتروني مسجل بالفعل. حاول تسجيل الدخول.';
          break;
        case 'weak-password':
          errorMessage =
              'كلمة المرور ضعيفة جدًا. يجب أن تكون 6 أحرف على الأقل.';
          break;
        case 'invalid-email':
          errorMessage = 'صيغة البريد الإلكتروني الذي أدخلته غير صحيحة.';
          break;
        default:
          errorMessage = 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى.';
      }
      showCustomSnackBar(
          context: context, content: errorMessage, isError: true);
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // 1. التحقق من صلاحية الإيميل أولاً (حتى لا نكشف وجوده إذا لم يكن مصرحاً به)
      final isAllowed = await isEmailWhitelisted(email);
      if (!context.mounted) return;

      if (!isAllowed) {
        showCustomSnackBar(
          context: context,
          content: 'عذراً، هذا البريد الإلكتروني غير مصرح له باستخدام التطبيق.',
          isError: true,
        );
        return;
      }

      // 2. محاولة تسجيل الدخول
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      String errorMessage;
      switch (e.code) {
        // هذه الحالة تعني أن الإيميل غير موجود في قاعدة بيانات Firebase Authentication
        case 'user-not-found':
        case 'invalid-email': // دمجها لأن النتيجة للمستخدم واحدة
          errorMessage = 'هذا البريد الإلكتروني غير مسجل. هل تريد إنشاء حساب؟';
          break;
        // هذه الحالة تعني أن الإيميل موجود ولكن كلمة السر خطأ
        case 'wrong-password':
        case 'invalid-credential':
          errorMessage = 'كلمة المرور التي أدخلتها غير صحيحة.';
          break;
        case 'user-disabled':
          errorMessage = 'تم تعطيل هذا الحساب من قبل المسؤول.';
          break;
        default:
          errorMessage = 'حدث خطأ. تأكد من اتصالك بالإنترنت وحاول مجدداً.';
      }
      showCustomSnackBar(
          context: context, content: errorMessage, isError: true);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

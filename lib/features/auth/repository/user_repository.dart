// lib/features/auth/repository/user_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inner_circle/core/models/user_model.dart';

// هذا المستودع مسؤول عن كل ما يتعلق ببيانات المستخدمين في Firestore
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // دالة لحفظ بيانات المستخدم لأول مرة بعد إنشاء الحساب
  Future<void> saveUserDataToFirestore({
    required BuildContext context,
    required String name,
    required User firebaseUser, // المستخدم القادم من Firebase Auth
  }) async {
    try {
      // إنشاء نموذج المستخدم بالبيانات الجديدة
      final user = UserModel(
        uid: firebaseUser.uid,
        name: name,
        email: firebaseUser.email ?? '', // نأخذ الإيميل مباشرة من حساب Firebase
        profilePic: '', // سنترك الصورة الرمزية فارغة في البداية
      );

      // حفظ بيانات المستخدم في Firestore داخل مجموعة 'users'
      // نستخدم uid الخاص بالمستخدم كمعرّف للمستند لسهولة الوصول إليه لاحقاً
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(user.toMap());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('حدث خطأ أثناء حفظ الملف الشخصي: ${e.toString()}')),
        );
      }
    }
  }

  // دالة لجلب بيانات مستخدم معين من Firestore
  // ستكون هذه الدالة حيوية جداً في main.dart
  Future<UserModel?> getUserData(String uid) async {
    final docSnap = await _firestore.collection('users').doc(uid).get();
    if (docSnap.exists) {
      return UserModel.fromMap(docSnap.data()!);
    }
    return null; // نرجع null إذا لم نجد ملفاً شخصياً للمستخدم
  }
}

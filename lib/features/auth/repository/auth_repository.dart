// features/auth/repository/auth_repository.dart (النسخة النهائية الكاملة)
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

  // Stream لمراقبة حالة تسجيل الدخول والخروج بشكل فوري
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
      final isAllowed = await isEmailWhitelisted(email);
      if (!isAllowed) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('هذا البريد الإلكتروني غير مصرح له بالانضمام')),
          );
        }
        return;
      }
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'حدث خطأ')));
      }
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'حدث خطأ')));
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

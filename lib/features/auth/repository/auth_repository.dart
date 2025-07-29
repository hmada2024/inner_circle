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

  // دالة للتحقق مما إذا كان الرقم في القائمة البيضاء
  Future<bool> isPhoneWhitelisted(String phoneNumber) async {
    try {
      final whitelistDoc =
          await _firestore.collection('settings').doc('whitelist').get();
      if (whitelistDoc.exists) {
        final List<dynamic> allowedPhones =
            whitelistDoc.data()?['allowedPhones'] ?? [];
        return allowedPhones.contains(phoneNumber);
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // دالة لبدء عملية المصادقة وإرسال OTP
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      final isAllowed = await isPhoneWhitelisted(phoneNumber);
      if (!isAllowed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('هذا الرقم غير مصرح له بالانضمام')),
        );
        return;
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
          // TODO: الانتقال إلى شاشة OTP مع verificationId
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message!)),
      );
    }
  }
}

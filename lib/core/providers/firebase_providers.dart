import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider لتوفير نسخة من FirebaseAuth
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

// Provider لتوفير نسخة من FirebaseFirestore
final firebaseFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);

// Provider لمراقبة حالة تسجيل دخول المستخدم (هذا سيحل أحد الأخطاء)
final authStateChangesProvider = StreamProvider((ref) {
  final authProvider = ref.watch(firebaseAuthProvider);
  return authProvider.authStateChanges();
});

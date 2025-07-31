import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // <<<--- تم إضافة هذا السطر
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider لتوفير نسخة من FirebaseAuth
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

// Provider لتوفير نسخة من FirebaseFirestore
final firebaseFirestoreProvider = Provider((ref) => FirebaseFirestore.instance);

// --- جديد: Provider لتوفير نسخة من FirebaseStorage ---
final firebaseStorageProvider = Provider((ref) => FirebaseStorage.instance);

// Provider لمراقبة حالة تسجيل دخول المستخدم
final authStateChangesProvider = StreamProvider((ref) {
  final authProvider = ref.watch(firebaseAuthProvider);
  return authProvider.authStateChanges();
});

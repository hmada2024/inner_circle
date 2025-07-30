// lib/features/auth/controller/user_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/models/user_model.dart';
import 'package:inner_circle/core/providers/firebase_providers.dart';
import 'package:inner_circle/features/auth/repository/user_repository.dart';

// Provider لتوفير نسخة من UserRepository
final userRepositoryProvider = Provider(
  (ref) => UserRepository(
    firestore: ref.read(firebaseFirestoreProvider),
  ),
);

// Provider للوصول إلى UserController
final userControllerProvider = Provider((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return UserController(userRepository: userRepository, auth: auth);
});

// Provider لجلب بيانات المستخدم الحالي بناءً على حالته
final userDataProvider = FutureProvider<UserModel?>((ref) {
  final userController = ref.watch(userControllerProvider);
  final currentUser = ref.watch(authStateChangesProvider).value;
  if (currentUser != null) {
    return userController.getUserData(currentUser.uid);
  }
  return null;
});

class UserController {
  final UserRepository _userRepository;
  final FirebaseAuth _auth;

  UserController({
    required UserRepository userRepository,
    required FirebaseAuth auth,
  })  : _userRepository = userRepository,
        _auth = auth;

  // تم تعديل الدالة لتكون async وتُرجع Future<void> للسماح للواجهة بانتظارها
  Future<void> saveUserDataToFirestore({
    required BuildContext context,
    required String name,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _userRepository.saveUserDataToFirestore(
        context: context,
        name: name,
        firebaseUser: currentUser,
      );
    }
  }

  Future<UserModel?> getUserData(String uid) {
    return _userRepository.getUserData(uid);
  }
}

// features/auth/controller/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/features/auth/repository/auth_repository.dart';
import 'package:inner_circle/core/providers/firebase_providers.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firebaseFirestoreProvider),
  ),
);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.watch(authRepositoryProvider),
  ),
);

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(false);

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true; // تفعيل حالة التحميل
    await _authRepository.signUpWithEmail(
        email: email, password: password, context: context);
    state = false; // إيقاف حالة التحميل
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true; // تفعيل حالة التحميل
    await _authRepository.signInWithEmail(
        email: email, password: password, context: context);
    state = false; // إيقاف حالة التحميل
  }
}

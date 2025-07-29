import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inner_circle/core/providers/firebase_providers.dart';
import 'package:inner_circle/features/auth/repository/auth_repository.dart';

// Provider لتوفير AuthRepository
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firebaseFirestoreProvider),
  ),
);

// Provider لتوفير AuthController
final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  // لاحظ هنا استخدمنا ref.watch بدلاً من تمرير الـ ref
  return AuthController(authRepository: authRepository);
});

class AuthController {
  final AuthRepository _authRepository;

  // قمنا بإزالة الـ ref من هنا
  AuthController({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  // سنقوم بتمرير الـ context مباشرة من الواجهة
  void signInWithPhone(BuildContext context, String phoneNumber) {
    _authRepository.signInWithPhone(context, phoneNumber);
  }
}

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
  return AuthController(authRepository: authRepository, ref: ref);
});

class AuthController {
  final AuthRepository _authRepository;
  final ProviderRef _ref;

  AuthController({
    required AuthRepository authRepository,
    required ProviderRef ref,
  })  : _authRepository = authRepository,
        _ref = ref;

  void signInWithPhone(BuildContext context, String phoneNumber) {
    _authRepository.signInWithPhone(context, phoneNumber);
  }
}
